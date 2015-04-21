# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Provider::Application.initialize!

#List of website for the application menu toolbar
if !defined?(OTHER_APPLICATIONS_URL)
  OTHER_APPLICATIONS_URL = {}
end

APPLICATION_NAME="Cerberus"
SUBTITLE_NAME="We know you !"
