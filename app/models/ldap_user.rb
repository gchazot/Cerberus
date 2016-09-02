def to_cn raw_group
    grp_hash = raw_group.rdns.find {|f| f.has_key? 'CN' }
    return grp_hash['CN']
end

#LDAP_FILTERS = YAML.load_file('config/ldap_filters.yml').deep_symbolize_keys()
 
class LdapGroup < ActiveLdap::Base

    ldap_mapping :dn_attribute => LDAP_FILTERS[:ldap_mapping_groups][:dn_attribute],
        :prefix => LDAP_FILTERS[:ldap_mapping_groups][:prefix],
        :classes => LDAP_FILTERS[:ldap_mapping_groups][:classes]
 
def self.build_filter group_names
    groups_filter = [:or]
    group_names.each do |group_name|
        # Net:Ldap can not handle special characters in filters :-(
        if group_name =~ /\~/
            logger.debug "Skipping unsupported group name #{group_name}"
            next
        end
        groups_filter.push({:cn => group_name})
    end
    return groups_filter
end

def get_parents_array
    parents = self.memberOf
        
    if parents.nil?
        return []
    elsif parents.is_a? Enumerable
        return parents
    else
        return [parents]
    end
end

def self.recurse_groups groups, already_seen, recursion
    if not groups
        logger.debug "Invalid groups"
        return []
    end
    if recursion <= 0
        logger.debug "Finished recursion"
        return []
    end
    
    groups_filter = build_filter groups
    all_groups = find(:all, :filter => groups_filter,)
    
    new_groups = Set.new
    all_groups.each do |group|
        parents = group.get_parents_array
        
        parents.each do |parent_raw|
            parent_cn = to_cn parent_raw
            seen = already_seen.add? parent_cn
            if !seen.nil?
                new_groups.add parent_cn
            end
        end
    end
    
    if new_groups.length > 0
        LdapGroup.recurse_groups new_groups, already_seen, recursion - 1
    end
    
    return already_seen
end
  
end

class LdapUser  < ActiveLdap::Base

    ldap_mapping :dn_attribute => LDAP_FILTERS[:ldap_mapping_users][:dn_attribute],
        :prefix => LDAP_FILTERS[:ldap_mapping_users][:prefix],
        :classes => LDAP_FILTERS[:ldap_mapping_users][:classes]
  
 def self.retrieve_information username
    retrieve_all_information username
 end
 
 def self.retrieve_groups username
    user_groups = Array.new
    if exists? username
        user = find(username)
        user_groups_raw = user.memberOf
        user_groups = user_groups_raw.map {|group_raw| to_cn group_raw}
    else
      logger.error "Error during search user : #{username} in LDAP"
    end

    return user_groups
 end
 
 def self.retrieve_all_groups username
    user_groups_cn = retrieve_groups username
    
    if user_groups_cn.length > 0
        seen_groups = Set.new user_groups_cn
        recursion = LDAP_FILTERS[:ldap_mapping_users][:max_groups_recursion]
        LdapGroup.recurse_groups user_groups_cn, seen_groups, recursion
        
        user_groups = seen_groups.to_a
    end

    logger.debug "Found #{user_groups.length} groups"
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
      if ldap_user_info.respond_to?(field) && ldap_user_info[field]!=nil
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
