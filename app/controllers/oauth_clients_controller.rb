class OauthClientsController < ApplicationController

  before_filter :login_required
  before_filter :get_client_application, :only => [:show, :edit, :update, :destroy]
 
  add_breadcrumb "Application List", {controller: "oauth_clients"}

  alias :login_required :authenticate_user!

  # Index page to list registered applications
  #
  # * *Call*    :
  #   - GET /BASE_URL/oauth_clients
  # * *Formats*    :
  #   - html
  #    
  def index
    @all_client_applications = ClientApplication.all.sort {|a,b| a.name <=> b.name }
    @client_applications = current_user.role.client_applications
    @tokens = current_user.tokens.find :all, :conditions => 'oauth_tokens.invalidated_at is null and oauth_tokens.authorized_at is not null'
  end

  # Form to declare a new application
  #
  # * *Call*    :
  #   - GET /BASE_URL/oauth_clients/new
  # * *Formats*    :
  #   - html
  #      
  def new
    @client_application = ClientApplication.new
  end


  # Method to register a new client application
  #
  # * *Call*    :
  #   - POST /BASE_URL/oauth_clients/1
  # * *Formats*    :
  #   - html
  # * *Args*    :
  #   - :client_application => {:name => "Client Application Name", :url => "Application URL", :support_url => "Application Support URL", :callback_url => "Application Callback URL", :poc => "Point Of Contact" }
  #
  def create
    @client_application = current_user.role.client_applications.build(params[:client_application])
    if @client_application.save
      flash[:notice] = "Registered '#{@client_application.name}' successfully"
      redirect_to :action => "show", :id => @client_application.id
    else
      flash.now[:error] = "Registration failed. #{@client_application.errors.full_messages}"
      render :action => "new"
    end
  end

  # Show client application information
  #
  # * *Call*    :
  #   - GET /BASE_URL/oauth_clients/show/1
  # * *Formats*    :
  #   - html
  # * *Args*    :
  #   - None
  #  
  def show
  end

  # Edit client application information
  #
  # * *Call*    :
  #   - GET /BASE_URL/oauth_clients/edit/1
  # * *Formats*    :
  #   - html
  # * *Args*    :
  #   - None
  #    
  def edit
  end

  # Method to update an existing client application 
  #
  # * *Call*    :
  #   - PUT /BASE_URL/oauth_clients/1
  # * *Formats*    :
  #   - html
  # * *Args*    :
  #   - :client_application => {:name => "Client Application Name", :url => "Application URL", :support_url => "Application Support URL", :callback_url => "Application Callback URL", :poc => "Point Of Contact" }
  #  
  def update
    if @client_application.update_attributes(params[:client_application])
      flash[:notice] = "Updated the client information of '#{@client_application.name}' successfully"      
      redirect_to :action => "show", :id => @client_application.id
    else
      flash.now[:error] = "Update failed for client application '#{@client_application.name}'. #{@client_application.errors.full_messages}"
      render :action => "edit"
    end
  end

  # Method to delete an existing client application 
  #
  # * *Call*    :
  #   - DELETE /BASE_URL/oauth_clients/1
  # * *Formats*    :
  #   - html
  # * *Args*    :
  #   - None
  #    
  def destroy
    @client_application.destroy
    flash[:notice] = "Destroyed the client application registration"
    redirect_to :action => "index"
  end

  # Page to list points of contact
  #
  # * *Call*    :
  #   - GET /BASE_URL/oauth_clients/list_pocs
  # * *Formats*    :
  #   - html
  #    
  def list_pocs
    if current_user.has_a_role_of("developer")      
      redirect_to oauth_clients_path, flash: { warning: "You are not allowed to see list of POCs when having a 'developer' role." }
    else
      #get app list per POC 
      @all_pocs = Hash.new([])
      ClientApplication.all.each do |client|
        if @all_pocs[client.poc].empty?
          @all_pocs[client.poc] = [ client.name ]
        else
          @all_pocs[client.poc].push(client.name)
        end
      end
      #get POC list filtering out default 'Not defined' POC
      @all_poc_names = @all_pocs.keys.keep_if { |poc| ! ( poc =~ /^Not defined$/ ) }.sort.join(", ")
      #rework POC app list sorting and joining app names
      @all_pocs.each do |poc, apps|
        @all_pocs[poc] = apps.sort.join(" / ")
      end      
    end
  end
  
  private
  # Helper method to retrieve client application looking at the logged user role
  
  def get_client_application
    unless @client_application = current_user.role.client_applications.find(params[:id])
      flash.now[:error] = "Wrong application id"
      raise ActiveRecord::RecordNotFound
    end
  end
end
