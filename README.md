#Cerberus

https://amadeusitgroup.github.io/Cerberus/

Cerberus is an authentication server for internal web application.
It identifies a user using Kerberos (password-less on Windows when using Integrated Authentication).

Then, it shares the identity with authorized applications.

## Getting started

Cerberus can be installed on any linux server, but for your convenience, we provide a Vagrantfile based on Ubuntu. You can follow the developer guide below to install it.

To set up an environment, please edit a file under config/environments/&lt;name&gt;.rb, such as production or integration.

Most notably, you will need to set `URL_OAUTH2_SERVER` to the url your instance will be running on.

### LDAP Setup
* LDAP configuration is located under config/ldap.yml. You will need to adjust them to point to your LDAP server.
* Fields mapping is located under config/ldap_filters.yml. They define how to map fields of your LDAP to the Cerberus users.

### (optional) Kerberos support
* Kerberos needs to configured on the host running Cerberus, with a valid keytab file.
* Kerberos support needs to be enabled in your environment configuration file.

Example :
````
config.middleware.use Rack::Auth::Krb::BasicAndNego, 'my realm', 'my keytab', nil, SECURED_URLS
````

### Starting your server
Example of startup script
````
export RAILS_ENV=production
export RACK_ENV=production
export SYSTEM_NODE=Common
bundle exec rails server mongrel -p 3000
````


## Developer Guide

You need :

- Git
- Vagrant
- The Vagrant plugin vagrant-librarian-chef
`vagrant plugin install vagrant-librarian-chef`

If you face the following issue (on Windows) :

* `An error occurred while installing chef (12.1.2), and Bundler cannot continue
Make sure that gem install chef -v '12.1.2' succeeds before bundling.
Gem::Installer::ExtensionBuildError: ERROR: Failed to build gem native extension.`

Run D:/Hashicorp/Vagrant/embedded/msys.bat as administrator and execute the following command :

* `GEM_HOME=$HOME/.vagrant.d/gems gem install chef --source=http://rubygems.org/`
and
* `vagrant plugin install vagrant-librarian-chef-nochef`

Then just use `vagrant up` to provision the virtual machine.

Once the VM is provisioned, 

* `vagrant ssh`

Within the VM

* `cd /vagrant`
* `bundle install` to set up the ruby dependencies.
* `rake db:migrate`
* `rake db:seed`
* Start the server using `./start_server.sh`

Generate docs

* `rake rapi_doc:setup` and `rake rapi_doc:generate`

