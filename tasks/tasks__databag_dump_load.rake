# in tasks dir

#
# Author:: Alexander Goldstein (<alexg-at-pangeaequity.com>)
# Copyright:: Copyright (c) 2008, 2009 Pangea Ventures, LLC
# License:: Apache License, Version 2.0
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
#

require 'chef/knife'
require 'ruby-debug'

def knife
  return @knife if @knife

  @knife = Chef::Knife.new 
  @knife.configure_chef
  @knife
end
# init upon load
knife

def rest; knife.rest end

def bags_dir
  File.join(TOPDIR, "databags")
end

def rest_create(path, json, item=(json['name']||json['id']))
  puts "creating %s/%s" % [path, item]
  rest.post_rest path, json
end

def rest_delete(path)
  puts "deleting %s" % path
  rest.delete_rest path
end

def rest_put(path, json)
  puts "updating %s" % path
  rest.put_rest path, json
end

def rest_get(path)
  rest.get_rest(path)
rescue Net::HTTPServerException => e
  raise unless e.to_s =~ /^404/
  return nil
end

def rest_put_if_changed(path, json)
  if rest_get(path) == json then
    puts "skipping #{path}"
  else
    rest_put path, json
  end
end

def bag_names
  Chef::DataBag.list.keys
end

def bag_by_name(bag_name)
  Chef::DataBag.load(bag_name).keys
end

def bag_item(bag_name, item_id)
  Chef::DataBagItem.load bag_name, item_id
end

directory bags_dir

desc "Dump out data bags"
task :dump_data_bags => bags_dir do

  bag_names.sort.each do |bag_name|
    puts "dumping #{bag_name}.."
    item_ids = bag_by_name bag_name
    items = item_ids.map do |item_id|
      bag_item bag_name, item_id
    end
    # TODO: limit number of backups
    fullname = File.join(bags_dir, bag_name) + '.json'
    time_suffix = Time.new.strftime("%Y%m%d_%H%M%S")
    File.rename(fullname, fullname+'.'+time_suffix) if File.exists?(fullname)

    File.open(fullname, 'w') do |out|
      out << JSON.pretty_generate(items)
      out << "\n"
    end
  end
end

# TODO: use DataBag interface
desc "Load data bags"
task :load_data_bags do
  files = Dir[ File.join(bags_dir, '*.json') ].map {|f| 
    File.basename(f, '.json')
  }

  new_bags = files - bag_names
  missing_files = bag_names - files
  bag_names_to_update = new_bags + (files & bag_names)

  new_bags.each do |bag_name|
    rest_create '/data', { 'name' => bag_name }
  end

  if ! missing_files.empty? then
    puts "Following bags don't have files to load: %s" % 
      missing_files.join(', ')
  end

  bag_names_to_update.each do |bag_name|
    fullname = File.join(bags_dir, bag_name) + '.json'
    json = File.read(fullname)
    content = JSON.parse json
    raise "array of items expected: #{json}" unless content.is_a?(Array)

    item_hash = content.inject({}) do |h,item| 
      raise "item missing id: %s" % JSON.pretty_generate(item) unless 
        item['id']
      h[item['id']] = item
      h
    end

    # file_item_ids = content.map{|item| item['id']}
    file_item_ids = item_hash.keys.sort
    item_ids = bag_by_name bag_name

    item_ids_with_bad_ids = file_item_ids.select {|item_id| 
      item_id !~ /^\w(\w|[-_])+$/ }
    unless item_ids_with_bad_ids.empty?
      raise "ERROR: item ids have invalid names: %s" % item_ids_with_bad_ids.join(' ')
    end

    ids_to_delete = item_ids - file_item_ids
    ids_to_create = file_item_ids - item_ids
    ids_to_update = item_ids & file_item_ids

    ids_to_update.each do |item_id|
      rest_put_if_changed "data/#{bag_name}/#{item_id}", item_hash[item_id]
    end

    ids_to_create.each do |item_id|
      rest_create "data/#{bag_name}", item_hash[item_id]
    end

    ids_to_delete.each do |item_id|
      rest_delete "data/#{bag_name}/#{item_id}"
    end
  end
end

