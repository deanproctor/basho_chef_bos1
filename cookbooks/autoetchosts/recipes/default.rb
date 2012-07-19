#
# Cookbook Name:: autoetchosts
#
# No Copyright.
#
# Based on http://powdahound.com/2010/07/dynamic-hosts-file-using-chef
# Use at your own risk.
#

# Find all nodes, sorting by Chef ID so their
# order doesn't change between runs.
#hosts = search(:node, "*:*", "X_CHEF_id_CHEF_X asc")
hosts = search(:node, "*:*")
 
template "/etc/hosts" do
  source "hosts.erb"
  owner "root"
  group "root"
  mode 0644
  variables(
    :hosts => hosts,
    :fqdn => node[:fqdn],
    :hostname => node[:hostname]
  )
end
