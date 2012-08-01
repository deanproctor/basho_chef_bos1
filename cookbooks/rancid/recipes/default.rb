#
# Cookbook Name:: rancid
# Recipe:: default
#
# Copyright 2012, Basho
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

case node[:platform]
when "ubuntu","debian"
  package "rancid" do
    action :install
  end
end

execute "rancid-cvs" do
  command "/var/lib/rancid/bin/rancid-cvs"
  action :run
  user "rancid"
end

template "/etc/rancid/rancid.conf" do
  source "rancid.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

template "/var/lib/rancid/.cloginrc" do
  source "cloginrc.erb"
  owner "rancid"
  group "rancid"
  mode 0600
end

template "/var/lib/rancid/boston/router.db" do
  source "router.db.erb"
  owner "rancid"
  group "rancid"
  mode 0644
end
