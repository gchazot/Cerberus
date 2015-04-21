class RestApiController < ApplicationController
  before_filter :login_required
  add_breadcrumb "API Documentation", {:controller => "rest_api", :action => "index"}, {:use_icon => "icon-th"}  

  alias :login_required :authenticate_user!
  
 def index
 	render :file => 'public/apidoc/index', :formats => [:html] and return
 end
end
