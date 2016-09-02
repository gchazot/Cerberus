class Api::UsersController < ApplicationController
  respond_to :json, :xml

before_filter :default_format_json

def default_format_json
  if(params[:format].nil?)
    request.format = "json"
  end
end

=begin apidoc?
 url:: /api/users/:name.[:format]
 method:: GET
 access:: FREE
 return:: [JSON|XML]
 param:: name:string - login or name of the user
 request::
 	/api/users/cnorris.json
 ::request-end::
 output:: json
   { "name":"Chuck NORRIS",
     "firstname":"Chuck",
     "lastname":"Norris",
     "login":"cnorris",
     "email":"cnorris@not-cerberus.com"
 }
 ::output-end::

 This service gives all available information on a user specified in parameter
=end

  def user_info
    user = User.find(:first, :conditions => "login = \"#{params[:name]}\" OR name = \"#{params[:name]}\"")
    if user.nil?
        #Research the user in LDAP If not yet existing in database
        user = User.find_or_create_from_ldap(params[:name])
    end
    respond_with ({:name => user.name, :firstname => user.firstname, :lastname => user.lastname,:login => user.login, :email => user.email})
  end


=begin apidoc?
 url:: /api/users/:name/belongs_to_group.[:format]?group_name=value
 method:: GET
 access:: FREE
 return:: [JSON|XML]
 param:: name:string - login of the user
 param:: group_name:string - the searched group name
 request::
 	/api/users/cnorris/belongs_to_group.json?group_name=cerberus_USERS
 ::request-end::
 output:: json
   {"result":false|true}
 ::output-end::

 This service indicates if a specified user belongs to a specific group
=end

  def user_belongs_to_group
    user = User.find(:first, :conditions => "login = \"#{params[:name]}\" OR name = \"#{params[:name]}\"")
    if user.nil?
        #Research the user in LDAP If not yet existing in database
        user = User.find_or_create_from_ldap(params[:name])
    end
    if user
        response = params[:group_name].nil? ? false : user.belongs_to_group(params[:group_name])
    else
        response = "false"
    end
    respond_with ({:result => response})
  end

=begin apidoc?
 url:: /api/users/groups.[:format]
 method:: GET
 access:: PROTECTED
 return:: [JSON|XML]
 request::
  /api/user/groups.json
 ::request-end::
 output:: json
   {"groups":["cerberus_USERS","Func-DEV-PSP"]}
 ::output-end::

This service gives the groups of the authenticated user. This request is very fast as it retrieves only the 1st level groups of the user.
=end

  def user_groups
    user = User.find(:first, :conditions => "login = \"#{params[:name]}\" OR name = \"#{params[:name]}\"")
    respond_with ({:groups => user.retrieve_groups_from_ldap})
  end
  
=begin apidoc?
 url:: /api/users/all_groups.[:format]
 method:: GET
 access:: PROTECTED
 return:: [JSON|XML]
 request::
  /api/user/all_groups.json
 ::request-end::
 output:: json
   {"groups":["cerberus_USERS","Func-DEV-PSP"]}
 ::output-end::

This service gives all the groups of the authenticated user. This request can take several seconds as it needs to find group recursively !
=end

  def user_all_groups
    user = User.find(:first, :conditions => "login = \"#{params[:name]}\" OR name = \"#{params[:name]}\"")
    respond_with ({:groups => user.retrieve_all_groups_from_ldap})
  end

=begin apidoc?
 url:: /api/users/:name/get_devserver.[:format]
 method:: GET
 access:: FREE
 return:: [JSON|XML]
 param:: name:string - login of the user
 request::
 	/api/users/cnorris/get_devserver.json
 ::request-end::
 output:: json
   {"name":"ncepspdevxx"}
 ::output-end::

 This service returns the devserver name associated to a user
=end
  def user_devserver
    user = User.find(:first, :conditions => "login = \"#{params[:name]}\" OR name = \"#{params[:name]}\"")
    if user.nil?
        #Research the user in LDAP If not yet existing in database
        user = User.find_or_create_from_ldap(params[:name])
    end
    if user
        response = user.get_devserver
    else
        response = "none"
    end
    respond_with ({:name => response})
  end

=begin apidoc?
     url:: /api/users/:name/all_info.[:format]
     method:: GET
     access:: PROTECTED
     return:: [JSON|XML]
     request::
      /api/users/:name/all_info.json
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
     Information : The response is dependent of the server configuration and can contain more or less information
=end
      def user_all_info
        user = User.find(:first, :conditions => "login = \"#{params[:name]}\" OR name = \"#{params[:name]}\"")
        if user.nil?
            #Research the user in LDAP If not yet existing in database
            user = User.find_or_create_from_ldap(params[:name])
        end
        respond_with (user.all_info)
      end

end
