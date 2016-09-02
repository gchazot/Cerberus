#
# Cookbook Name:: cerberus
# Recipe:: default
#
# Copyright 2015, Vincent Latombe
#


class Chef::Recipe
  # mix in recipe helpers
  include Chef::RubyBuild::RecipeHelpers
end

mysql_service 'default' do
  version '5.6'
  bind_address '0.0.0.0'
  port '3306'  
  data_dir '/data'
  initial_root_password node['cerberus']['mysql']['initial_root_password']
  action [:create, :start]
end

mysql_client 'default' do
  action :create
end

mysql2_chef_gem 'default' do
  gem_version '0.3.17'
  action :install
end

mysql_connection_info = {:host => "127.0.0.1",
                         :username => 'root',
                         :password => node['cerberus']['mysql']['initial_root_password']}

mysql_database "CerberusDB" do
  connection mysql_connection_info
  action :create
end

mysql_database "CerberusDB_UT" do
  connection mysql_connection_info
  action :create
end

mysql_database_user 'cerberus' do
  connection mysql_connection_info
  password 'cerberus'
  action :create
end

mysql_database_user 'cerberus' do
  connection mysql_connection_info
  database_name 'CerberusDB'
  host '%'
  action :grant
end

mysql_database_user 'cerberus' do
  connection mysql_connection_info
  database_name 'CerberusDB_UT'
  host '%'
  action :grant
end

apt_package 'bundler'

execute 'bundler-install' do
    user 'vagrant'
    cwd '/vagrant'
    environment ({
        'HOME' => '/home/vagrant',
        'PATH' => "/home/vagrant/.rbenv/shims:/home/vagrant/.rbenv/bin:#{ENV['PATH']}"
    })
    command 'bundle install'
    action :run
end
