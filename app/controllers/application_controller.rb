require "statsd_manager"

class UnauthorizedException < Exception; end

class ApplicationController < ActionController::Base

  protect_from_forgery

  helper_method :current_user
  attr_accessor :current_user
  helper_attr :current_user

  # Entry point of application redirecting to OauthClient controller index action
  #
  # * *Call*    :
  #   - GET /BASE_URL/
  # * *Formats*    :
  #   - html
  #
  def index
    redirect_to(:controller => "oauth_clients")
  end

  # Helper method to set current_user object
  #
  def current_user=(user)
    @current_user = user
  end

  # Helper method to get current_user object
  #
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  # This method is called when we need to check If a user is already authenticated
  # If he is not authenticated then we will display a Loading popup during the authentication
  #
  def authenticate_user!
    if !env['HTTP_AUTHORIZATION'].nil?
        # authentification with reverse proxy setting HTTP_AUTHORIZATION header
        user, pass = Base64.decode64(env['HTTP_AUTHORIZATION'].split[1]).split ':', 2
    elsif !request.env['REMOTE_USER'].nil?
        user = request.env['REMOTE_USER']
    else
        user = nil
    end

    if !user.nil?
      #If user is already logged in, we do not retrieve again his information from ldap
      if session[:user_id].nil?
        authenticated_user = User.find_or_create_from_ldap(user)
        if authenticated_user
          session[:user_id] = authenticated_user.id
          statsd = StatsManager.new
          statsd.feedLoginMetric(authenticated_user)
        else
          flash[:error] = "User information can not been retrieved. Please contact support team."
          return false
        end
      end
      return true
    else
      #We have two handle two different entry point
      #1 - The user tries to access directlty to an application page
      #2 - The user comes from another client application


      @request_uri = ( (env["REQUEST_URI"].nil?) ? oauth_clients_path : env["REQUEST_URI"])
      #The if is just a rewrite of an old url we can not decomission as some clients still use it:
      #If the uri contains service=cli in its GET paramters, we change the calling uri from authorize to authorize_cli
      if @request_uri.match(/service=cli/)
        redirect_to @request_uri.sub("/#{BASE_URL}/oauth/authorize", "/#{BASE_URL}/oauth/authorize_cli")
      else
        #We display the views containing a popup and starting AJAX to process kerberos authentication
        #1- User wants to access an application page
        if !@request_uri.match(/\/#{BASE_URL}\/oauth\//)
          @query = "scope=#{BASE_URL}&redirect_uri=" + @request_uri
        else
        #2 - User has been redirected on the application via a client application
          #We will forward the GET parameters into the ajax call
          @query = params.to_query
        end
        render "authenticate", :layout => false
      end
    end

  end

  # This method is just use to allow an anonymous connection to check if the application is alive or not
  #
  # * *Call*    :
  #   - GET /BASE_URL/check
  # * *Formats*    :
  #   - html
  #
  def check
    render :file => 'public/check', :formats => [:html], :layout => false and return
  end


  # This method is called through an AJAX call when a user comes from a client application, we asynchronously do the authentication
  # And according to the suces or not we send as a result an url of a page to display
  #
  # * *Call*    :
  #   - GET /BASE_URL/authenticate_user
  # * *Formats*    :
  #   - html
  # * *Args*    :
  #   - scope: If it is the BASE_URL It means that we are acessing directly the application otherwise, we are a client application
  #   - redirect_uri: It will be the url to redirect user to (If coming from the application)
  #   There are other params which can be passed in the case of a client application, they are dynamically created in authenticate_user!
  #
  def authenticate_user
    if !env['HTTP_AUTHORIZATION'].nil?
        # authentification with reverse proxy setting HTTP_AUTHORIZATION header
        user, pass = Base64.decode64(env['HTTP_AUTHORIZATION'].split[1]).split ':', 2
    elsif !request.env['REMOTE_USER'].nil?
        user = request.env['REMOTE_USER']
    else
        user = nil
    end

    if !user.nil?
        logger.debug "Logging user #{user}"

        #puts "You have been automatically authenticated as #{session['REMOTE_USER']} thanks to kerberos !"
        #If user is already logged in the application, we do not retrieve again his information from ldap
        if session[:user_id].nil?
          authenticated_user = User.find_or_create_from_ldap(user)
          if authenticated_user
            session[:user_id] = authenticated_user.id
          else
            flash[:error] = "User information can not been retrieved. Please contact support team."
            render :text => authentication_failed_path
          end
        end

        if params[:response_type].nil?
          params[:response_type] = "code"
        end

        #1- User wants to access a page
        if !params[:scope].nil? && params[:scope] == "#{BASE_URL}"
          render :text => params[:redirect_uri]
        else
        #2 - User has been redirected on the application via a client application
          @authorizer = OAuth::Provider::Authorizer.new current_user, true, params
          render :text => @authorizer.redirect_uri
        end

    else
      render :text => authentication_failed_path
    end

  end

  # Page to display a Authentication has Failed message
  #
  # * *Call*    :
  #   - GET /BASE_URL/authentication_failed
  # * *Formats*    :
  #   - html
  #
  def authentication_failed
    render "authentication_failed", :layout => false
  end
end
