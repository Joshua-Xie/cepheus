#
# Author:: Hans Chris Jones <chris.jones@lambdastack.io>
# Cookbook Name:: cepheus
#
# Copyright 2018, LambdaStack
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# So some Ceph tools will find librados if the tool needs to be built.
# sudo ln -s /usr/lib64/librados.so.2.0.0 /usr/lib64/librados.so

execute 'symlink-librados' do
  command "ln -s /usr/lib64/#{node['ceph']['librados_version']} /usr/lib64/librados.so"
  ignore_failure true
end

# Add user to 'ceph' group if it exists. Can only run after Ceph is installed.
node['cepheus']['users'].each do | user_value |
    execute "add_user_to_ceph_#{user_value['name']}" do
      command "usermod -a -G ceph #{user_value['name']}"
      ignore_failure true
    end
end
