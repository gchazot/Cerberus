# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Use Ubuntu 14.04 Trusty Tahr 64-bit as our operating system
  config.vm.box = "ubuntu/trusty64"
  
  config.vm.hostname = "dev-cerberus.vagrant"

  # Configurate the virtual machine to use 2GB of RAM
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
    vb.customize ["modifyvm", :id, "--cpus", "2"]   
  end

  # Forward the Rails server default port to the host
  config.vm.network :forwarded_port, guest: 3000, host: 3000
  
  config.librarian_chef.cheffile_dir = "chef"

  # Use Chef Solo to provision our virtual machine
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ["chef/cookbooks", "chef/site-cookbooks"]
    chef.roles_path = "chef/roles"

    chef.add_recipe "apt"
    chef.add_recipe "ruby_build"
    chef.add_recipe "rbenv::user"
    chef.add_recipe "rbenv::vagrant"
    chef.add_recipe "vim"
    chef.add_recipe "krb5"
    chef.add_recipe "krb5::rkerberos_gem"
    chef.add_recipe "cerberus"

    # Install Ruby 2.1.2 and Bundler
    # Set an empty root password for MySQL to make things simple
    chef.json = {
      rbenv: {
        user_installs: [{
          user: 'vagrant',
          rubies: ["2.1.2"],
          global: "2.1.2",
          gems: {
            "2.1.2" => [
              { name: "bundler" },
              { name: "rake" },
              { name: "byebug" }
            ]
          }
        }]
      },
      krb5: {
        krb5_conf: {
          libdefaults: {
            default_realm: 'workgroup'
          },
          realms: {
            workgroup: [ "iis.domain.net" ]
          }
        }
      },
      bundler: {
        apps_path: "/vagrant"
      },
      cerberus: {
        database: {
          username: "cerberus",
          password: "cerberus"
        },
        mysql: {
          initial_root_password: "Ch4ng3me"
        }
      }
    }
  end
end