class LdapUser  < ActiveLdap::Base

 #LDAP_FILTERS = YAML.load_file('config/ldap_filters.yml').deep_symbolize_keys()

 ldap_mapping :dn_attribute => LDAP_FILTERS[:ldap_mapping][:dn_attribute], 
  :prefix => LDAP_FILTERS[:ldap_mapping][:prefix],
  :classes => LDAP_FILTERS[:ldap_mapping][:classes]

 def self.retrieve_information username
    retrieve_all_information username
 end

 def self.retrieve_groups username
    user_groups = Array.new
    if exists? username
      user_groups_raw = find(username).memberof
      user_groups_raw.each do |group_raw|
         grp_hash = group_raw.rdns.find {|f| f.has_key? 'CN' }
         user_groups.push grp_hash['CN']
      end
    else
      logger.error "Error during search user : #{username} in LDAP"
    end

    return user_groups
 end  

 def self.belongs_to_group username, groupname
    user_groups = retrieve_groups username
    user_groups.include? groupname
 end    
 
 def self.retrieve_all_information username
  user_info = Hash.new
  wished_fields = LDAP_FILTERS[:ldap_user_wished_fields]
  if exists? username
    ldap_user_info = find(username)
    wished_fields.each do |field, key|
      if ldap_user_info.respond_to?(field)
        user_info[key] = ldap_user_info[field]
      else
        user_info[key] = "N/A" 
      end
    end
    user_info.symbolize_keys!
  else
      logger.error "Error during search user : #{username} in LDAP"  
  end  
  return user_info
end

end
