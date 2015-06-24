require 'oauth/controllers/provider_controller'
class OauthController < ApplicationController
  
  add_breadcrumb "Authentication", {:controller => "oauth", :action => "login"}, {:use_icon => "icon-th"}  


  # Action to change current user role to admin If applicable 
  #
  # * *Call*    :
  #   - GET /BASE_URL/oauth/be_admin
  # * *Formats*    :
  #   - html
  #    
  def be_admin
    if current_user.switch_to("admin")
      flash[:notice] = "You have now an 'admin' role"
    else
      flash[:error] = "You are not authorized to have a 'admin' role"
    end
    redirect_to( request.env["HTTP_REFERER"])
  end
  
  # Action to change current user role to developer If applicable 
  #
  # * *Call*    :
  #   - GET /BASE_URL/oauth/be_developer
  # * *Formats*    :
  #   - html
  #    
  def be_developer
    if current_user.switch_to("developer")
      flash[:notice] = "You have now a 'developer' role"
    else
      flash[:error] = "You are not authorized to have a 'developer' role"
    end    
    redirect_to( request.env["HTTP_REFERER"] )
  end  
    
  # Action to allow a user to get logged with other credentials
  #
  # * *Call*    :
  #   - GET /BASE_URL/oauth/login
  # * *Formats*    :
  #   - html
  #      
  def login
    #If we go to login page we clear all data still in session to force a re-auth
    current_user = nil
    session[:user_id] = nil
    session["REMOTE_USER"] = nil
    env["REMOTE_USER"] = nil
     if params[:redirect_uri].nil? or params[:client_id].nil?
       redirect_to root_path
     else
      @from_application = ClientApplication.find_by_callback_url(params[:redirect_uri])
       if @from_application.nil?
         redirect_to root_path
       end         
     end
     
  
  end
    
  include OAuth::Controllers::ProviderController

  alias :login_required :authenticate_user!

  # Action to manage authorization possibilities
  # 1 - Request comes from the login page, we will render the redirect_uri of the client application
  #
  # * *Call*    :
  #   - GET/POST /BASE_URL/oauth/authorize
  # * *Formats*    :
  #   - html
  #      
      def authorize
        if params[:response_type].nil?
          params[:response_type] = "code"
        end
        @authorizer = OAuth::Provider::Authorizer.new current_user, true, params
        client_application = ClientApplication.find_by_key(params[:client_id])
        statsd = StatsManager.new
        statsd.feedAuthorizeMetric(current_user)
        #If this is an auto authentication transparent for end user
        redirect_to @authorizer.redirect_uri
      end

  # Action to manage authorization possibilities
  # 21- Request comes from a command line tool, we will render the token value
  #
  # * *Call*    :
  #   - GET/POST /BASE_URL/oauth/authorize_cli
  # * *Formats*    :
  #   - html
  #      
      def authorize_cli
        authenticate_user!
        if params[:response_type].nil?
          params[:response_type] = "code"
        end
        @authorizer = OAuth::Provider::Authorizer.new current_user, true, params  
        client_application = ClientApplication.find_by_key(params[:client_id])
        statsd = StatsManager.new
        statsd.feedAuthorizeMetric(current_user, client_application)
        render :text => @authorizer.code.token
      end      


  # Action to manage authorization possibilities
  # 1 - Request comes from a client application, we will redirect user to redirect_uri  
  #
  # * *Call*    :
  #   - GET/POST /BASE_URL/oauth/authorize_switch_user
  # * *Formats*    :
  #   - html
  #      
      def authorize_switch_user
        authenticate_user!
        if params[:response_type].nil?
          params[:response_type] = "code"
        end
        @authorizer = OAuth::Provider::Authorizer.new current_user, true, params  
        render :text => @authorizer.redirect_uri
      end               
end
