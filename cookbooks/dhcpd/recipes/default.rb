#
# Cookbook Name:: dhcpd
# Recipe:: default
#
# Copyright 2011, Joshua SS Miller
#

service "dhcpd" do
  service_name node[:dhcpd][:service]
end

package "dhcpd" do
  package_name node[:dhcpd][:package] 
  if node[:dhcpd][:version]
    version node[:dhcpd][:version]
    action :install
  else
    action :install
  end
end

template node[:dhcpd][:default_file] do
  source "dhcp3-server.erb"
  owner "root"
  group "root"
  mode 0644
  notifies(:restart, resources(:service => "dhcpd"))
end

template node[:dhcpd][:dhcpd_conf_file] do
  source "dhcpd.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables(
#    :secret => search(:zones, "domain:#{node[:dhcpd][:domain]} AND ddns:true" ).first["secret"]
    )
  notifies(:restart, resources(:service => "dhcpd"))
end
