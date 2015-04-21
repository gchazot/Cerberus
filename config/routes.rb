Provider::Application.routes.draw do

   name_regex = /[A-Za-z0-9\.\-_]+?/

  scope "#{BASE_URL}" do

    match '/oauth_clients/list_pocs', to: 'oauth_clients#list_pocs', as: :list_pocs
    resources :oauth_clients
    
    match '/oauth/test_request',          :to => 'oauth#test_request',          :as => :test_request
    match '/oauth/token',                 :to => 'oauth#token',                 :as => :token
    match '/oauth/access_token',          :to => 'oauth#access_token',          :as => :access_token
    match '/oauth/request_token',         :to => 'oauth#request_token',         :as => :request_token
    match '/oauth/authorize',             :to => 'oauth#authorize',             :as => :authorize
    match '/oauth/authorize_cli',         :to => 'oauth#authorize_cli',         :as => :authorize_cli
    match '/oauth/authorize_switch_user', :to => 'oauth#authorize_switch_user', :as => :authorize_switch_user
    match '/oauth',                       :to => 'oauth#index',                 :as => :oauth
    match "/oauth/authenticate",          :to => 'oauth#authorize',             :as => :authorize
  
    #Jenkins routes
    match '/login/oauth/authorize',     :to => 'oauth#authorize',     :as => :authorize
    match '/login/oauth/access_token',  :to => 'oauth#access_token',  :as => :access_token
    match '/login/oauth/request_token', :to => 'oauth#request_token', :as => :request_token
    match '/login/oauth/token',         :to => 'oauth#token',         :as => :token    
    
    match '/oauth/login',        :to => 'oauth#login',        :as => :login
    match '/oauth/login_as',     :to => 'oauth#login_as',     :as => :login_as
    match '/oauth/be_admin',     :to => 'oauth#be_admin',     :as => :be_admin
    match '/oauth/be_developer', :to => 'oauth#be_developer', :as => :be_developer
    
  	#API Documentation
  	match '/rest_api', :to => 'rest_api#index'
  	
    match '/authenticate',          :to => 'application#authenticate'
    match '/authenticate_user',     :to => 'application#authenticate_user'
    match '/authentication_failed', :to => 'application#authentication_failed'
    
    root :to => "application#index"
 
    namespace :api do
      match "getInfo"                      => "user#info" #keep old naming used in first version
      match "user.info"                    => "user#info"
      match "user.all_info"                => "user#all_info"
      match "user.name"                    => "user#name"
      match "user.login"                   => "user#login"
      match "user.email"                   => "user#email"
      match "user.groups"                  => "user#groups"
      match "user.firstname"               => "user#firstname"
      match "user.lastname"                => "user#lastname"
      match "user.belongs_to_group"        => "user#belongs_to_group"
      match "user.all_info"                => "user#all_info"      
      match "users/:name"                  => "users#user_info", :name => name_regex, :format => /json|xml|yaml/
      match "users/:name/belongs_to_group" => "users#user_belongs_to_group" , :name =>name_regex, :format => /json|xml|yaml/
      match "users/:name/get_devserver"    => "users#user_devserver", :name => name_regex, :format => /json|xml|yaml/
      match "users/:name/all_info"         => "users#user_all_info", :name => name_regex, :format => /json|xml|yaml/
      match "users/:name/groups"           => "users#user_groups", :name => name_regex, :format => /json|xml|yaml/
    end
 
    match "/check" => "application#check"
    match "/401"   => "errors#unauthorized"
    match "/404"   => "errors#not_found"
    match '*path'  => "errors#not_found"
     
  end
  
end
