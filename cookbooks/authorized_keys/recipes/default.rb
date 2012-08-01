#
# Cookbook Name:: authorized_keys
# Recipe:: default
#
# Copyright 2012, Basho Technologies, Inc
#

require_recipe 'sudo'

groups = node['authorization']['sudo']['groups'].map{ |v|  %Q(#{v}) }.join(' ')

log "#{groups}"

package "ldap-utils" do
  action :install
end

cookbook_file "/usr/bin/manage_authorized_keys.sh" do
  source "manage_authorized_keys.sh"
  mode 0700
  owner "root"
  group "root"
  action :create
end

execute "manage_authorized_keys" do
  command "/usr/bin/manage_authorized_keys.sh #{node[:authorized_keys][:admin_group]} #{groups}"
  action :run
end
