class Api::UserController < ApplicationController
  respond_to :json, :xml

  oauthenticate :interactive => false
   
  before_filter :get_user_info, :default_format_json

	def default_format_json
	  if(params[:format].nil?)
	    request.format = "json"
	  end
  end
=begin apidoc?
 url:: /api/user.info.[:format]
 method:: GET
 access:: PROTECTED
 return:: [JSON|XML]
 request::
 	/api/user.info.json?access_token=your_personal_access_token
 ::request-end::  
 output:: json
   { "name":"Chuck NORRIS",
     "firstname":"Chuck",
     "lastname":"Norris",
     "login":"cnorris",
     "email":"cnorris@not-cerberus.com"
 }
 ::output-end::
 
 This service gives all available information about the authenticated user
=end       
  def info
    respond_with ({:name => @user.name, :firstname => @user.firstname, :lastname => @user.lastname,:login => @user.login, :email => @user.email})
  end 
  

=begin apidoc?
 url:: /api/user.name.[:format]
 method:: GET
 access:: PROTECTED
 return:: [JSON|XML]
 request::
 	/api/user.name.json?access_token=your_personal_access_token
 ::request-end::   
 output:: json
   { "name":"Chuck NORRIS"}
 ::output-end::
 
This service gives the full name of the authenticated user
=end         
  def name
    respond_with ({:name => @user.name})    
  end
  
=begin apidoc?
 url:: /api/user.login.[:format]
 method:: GET
 access:: PROTECTED
 return:: [JSON|XML]
 request::
 	/api/user.login.json?access_token=your_personal_access_token
 ::request-end::   
 output:: json
   { "login":"cnorris"}
 ::output-end::
 
This service gives the login of the authenticated user
=end      
  def login
    respond_with ({:login => @user.login})    
  end

=begin apidoc?
 url:: /api/user.email.[:format]
 method:: GET
 access:: PROTECTED
 return:: [JSON|XML]
 request::
 	/api/user.email.json?access_token=your_personal_access_token
 ::request-end::   
 output:: json
   { "email":"cnorris@not-cerberus.com"}
 ::output-end::
 
This service gives the email of the authenticated user
=end     
  def email
    respond_with ({:email => @user.email})    
  end
  
=begin apidoc?
 url:: /api/user.firstname.[:format]
 method:: GET
 access:: PROTECTED
 return:: [JSON|XML]
 request::
 	/api/user.firstname.json?access_token=your_personal_access_token
 ::request-end::   
 output:: json
   { "firstname":"Chuck"}
 ::output-end::
 
This service gives the firstname of the authenticated user
=end     
  def firstname
    respond_with ({:firstname => @user.firstname})    
  end
 
=begin apidoc?
 url:: /api/user.lastname.[:format]
 method:: GET
 access:: PROTECTED
 return:: [JSON|XML]
 request::
 	/api/user.lastname.json?access_token=your_personal_access_token
 ::request-end::   
 output:: json
   { "lastname":"Norris"}
 ::output-end::
 
This service gives the lastname of the authenticated user
=end         
  def lastname
    respond_with ({:lastname => @user.lastname})    
  end

  
=begin apidoc?
 url:: /api/user.groups.[:format]
 method:: GET
 access:: PROTECTED
 return:: [JSON|XML]
 request::
 	/api/user.groups.json?access_token=your_personal_access_token
 ::request-end::   
 output:: json
   {"groups":["cerberus_USERS","Func-DEV-PSP"]}
 ::output-end::
 
This service gives the groups of the authenticated user. This request can take several seconds as it needs to find group recursively !
=end
  def groups
    respond_with ({:groups => @user.retrieve_groups_from_ldap})    
  end  

=begin apidoc?
 url:: /api/user.belongs_to_group.[:format]?group_name=value
 method:: GET
 access:: PROTECTED
 return:: [JSON|XML]
 request::
 	/api/user.belongs_to_group.json?group_name=cerberus_USERS&access_token=your_personal_access_token
 ::request-end::   
 param:: group_name:string - the searched group name
 output:: json
   {"result":true}
 ::output-end::
 
This service indicates if the authenticated user belongs to a specific group
=end
    
  def belongs_to_group
    response = params[:group_name].nil? ? false : @user.belongs_to_group(params[:group_name])
    respond_with ({:result => response})    
  end    

=begin apidoc?
     url:: /api/user.all_info.[:format]
     method:: GET
     access:: PROTECTED
     return:: [JSON|XML]
     request::
      /api/user.all_info.json?access_token=your_personal_access_token
     ::request-end::  
     output:: json
      {
        "email": "cnorris@not-cerberus.com",
        "name": "Chuck NORRIS",
        "firstname": "Chuck",
        "lastname": "Norris",
        "country": "France",
        "location": "City",
        "description": "Dev. & Tools Environment",
        "postalcode": "01111",
        "office": "VB112",
        "phone": "+33 1 2345 6789",
        "created_at": "20121026141649.0Z",
        "updated_at": "20130801061114.0Z",
        "department": "R&D-CERBERUS",
        "company": "cerberus sas",
        "streetaddress": "cerberus adress",
        "contract": "CDI"
      }  
    ::output-end::
     
     This service gives all available information about the authenticated user
=end       
    def all_info
      respond_with (@user.all_info)
    end   
    
  private 
  
  # This private method helps retrieving authenticated user information
  #
  # * *Args*    :
  #   - None
  # * *Returns* :
  #   - User object
  #         
  def get_user_info
    userTokenInfo = request.env['oauth.token']
    @user = userTokenInfo.user    
  end
end
