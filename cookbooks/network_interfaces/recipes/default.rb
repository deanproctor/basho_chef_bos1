#
# Cookbook Name:: network_interfaces
# Recipe:: default
#
# Copyright 2012, Basho Technologies, Inc.
#
node_id = node[:fqdn].gsub('.', '_')

network_interfaces = search(:network_interfaces, %Q{id:"#{node_id}"})

unless network_interfaces.empty?
  template "/etc/network/interfaces" do
    source "interfaces.erb"
    owner "root"
    group "root"
    mode 0644
    variables(
      :interfaces => network_interfaces.first['interfaces']
    ) 
  end
end

template "/etc/iproute2/rt_tables" do
  source "rt_tables.erb"
  owner "root"
  group "root"
  mode 0644
end

template "/etc/dhcp/dhclient-exit-hooks.d/ip-route" do
  source "ip-route.erb"
  owner "root"
  group "root"
  mode 0644
end
