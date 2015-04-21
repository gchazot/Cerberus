require 'i18n/core_ext/hash'
LDAP_FILTERS = YAML.load_file("#{Rails.root.to_s}/config/ldap_filters.yml")[Rails.env].deep_symbolize_keys()
BASE_URL = 'cerberus'
SECURED_URLS=["/#{BASE_URL}/oauth_clients", "/#{BASE_URL}/rest_api", "/#{BASE_URL}/oauth/authorize_switch_user", "/#{BASE_URL}/oauth/authorize_cli", "/#{BASE_URL}/authenticate_user"]