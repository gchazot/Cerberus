class ErrorsController < ApplicationController
  
  layout "errors"
  def unauthorized
    # Will render the app/views/errors/unauthorized.html.haml template
    @error_code = "401"
    @error_title = action_name.capitalize
  end
 
  def not_found
    @error_code = "404"
    @error_title = action_name.capitalize
  end
 
  protected
 
  # The exception that resulted in this error action being called can be accessed from
  # the env. From there you can get a backtrace and/or message or whatever else is stored
  # in the exception object.
  def the_exception
    @e ||= env["action_dispatch.exception"]
  end
end