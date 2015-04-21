class User < ActiveRecord::Base

  belongs_to :role
  has_many :tokens, :class_name => "Oauth2Token", :order => "authorized_at desc", :include => [:client_application]

  validates_presence_of :login
  ADMIN_FUNCTIONAL_GROUP = LDAP_FILTERS[:admin_functional_group]

  # Call to LdapUser class to retrieve groups the user belongs to
  #
  # * *Args*    :
  #   - None
  # * *Returns* :
  #   - ["group1","group2",...]
  #  

  def retrieve_groups_from_ldap
    LdapUser.retrieve_groups self.login
  end
  # Check if the user belongs to a specific group requesting it to Ldap
  #
  # * *Args*    :
  #   - group_name: The group name for the one we search if the user belongs to
  # * *Returns* :
  #   - false/true
  #    
  def belongs_to_group group_name
    res = LdapUser.belongs_to_group(self.login, group_name)    
  end
  # Return the user's devserver
  #
  # * *Args*    :
  #   - None
  # * *Returns* :
  #   - String devserver name
  #    
  def get_devserver
    devserver = all_info[:devserver]
    if devserver!=nil
      return devserver.split(':').last
    end
  end  

  
  # Retrieve or create a user in database requesting his information from Ldap
  #
  # * *Args*    :
  #   - kerberos_login: login as it is obtain thanks to kerberos authentication
  # * *Returns* :
  #   - User
  #      
  def self.find_or_create_from_ldap(kerberos_login)

    login = kerberos_login.split("\@").first
    user = User.find_by_login( login )
    user_information = LdapUser.retrieve_information login 
    if user_information.empty?
      return nil
    end

    begin

      # We've been unable to find out an internal user in our db: let's create one
      if user.nil?
        user = User.create_with_default_preferences( login, user_information[:name], user_information[:firstname], user_information[:lastname], user_information[:email], "developer")
      else
        user.email = user_information[:email]
        user.name = user_information[:name]
        user.firstname = user_information[:firstname]
        user.lastname = user_information[:lastname]
        
      end
    rescue => err
      logger.error "User '#{login}' update failed: " + err.to_s      
    end
    user.save!
    role = (user.belongs_to_group(ADMIN_FUNCTIONAL_GROUP)) ? "admin" : "developer"
    user.role = Role.find_by_name(role)  
    user.save!
    return user
  end

  # Create a user in database
  #
  # * *Args*    :
  #   - login: login of user
  #   - name: name of user
  #   - firstname: first name of user
  #   - lastname: last name of user
  #   - email: email of user
  #   - role : developer or admin
  # * *Returns* :
  #   - User
  #    
  def self.create_with_default_preferences(login, name,  firstname, lastname, email, role)
    user = User.create( :login => login, :name => name, :firstname => firstname, :lastname => lastname, :email => email, :role => Role.find_by_name(role))
    begin
      user.save!
    rescue => err
      logger.error "User '#{login}' creation failed " + err.to_s
      user = nil
    else
      logger.error "User '#{login}' created."
    end

    return user
  end

  # Does the user play indcating +role+
  #
  # * *Args*    :
  #   - role: role we look for
  # * *Returns* :
  #   - false/true
  #
  def has_a_role_of( role )
    return self.role.name == role
  end

  # Does the user belongs to DTE functional group
  #
  # * *Args*    :
  #   - None
  # * *Returns* :
  #   - false/true
  #  
  def is_admin?
    return self.belongs_to_group(ADMIN_FUNCTIONAL_GROUP)
  end

  # Change the user role If he has admin privileges
  #
  # * *Args*    :
  #   - role: Wished role
  # * *Returns* :
  #   - false/true
  #    
  def switch_to(role)
    if self.is_admin?
      self.role = Role.find_by_name(role)
      self.save!
      return true
    else
      return false
    end
  end

  # Return all useful LDAP user's information 
  #
  # * *Args*    :
  #   - None
  # * *Returns* :
  #   - Array user ldap informations
  #     
  def all_info
    LdapUser.retrieve_all_information self.login 
  end
  
end
