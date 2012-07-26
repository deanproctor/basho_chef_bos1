#
# Cookbook Name:: authorized_keys
# Recipe:: default
#
# Copyright 2012, Basho Technologies, Inc
#

package "ldap-utils" do
  action :install
end

remote_file "/usr/bin/manage_authorized_keys.sh" do
  source "manage_authorized_keys.sh"
  mode 0700
  owner "root"
  group "root"
  action :create
end

execute "manage_authorized_keys" do
  command "/usr/bin/manage_authorized_keys.sh #{node[:authorized_keys][:admin_group]} #{node[:authorized_keys][:groups]}"
  action :run
end
