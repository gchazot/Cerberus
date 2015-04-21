class Role < ActiveRecord::Base
  attr_accessible :name
  
  has_many :client_applications
  has_many :tokens, :class_name => "Oauth2Token", :order => "authorized_at desc", :include => [:client_application]
  has_many :users
end
