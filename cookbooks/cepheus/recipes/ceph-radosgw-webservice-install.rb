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

#if node['cepheus']['ceph']['radosgw']['rgw_webservice']['enable']
if node['ceph']['radosgw']['rgw_webservice']['enable']
    # This recipe installs everything needed for the RGW Admin Web Service...

    package 'nginx' do
      action :upgrade
    end

    include_recipe 'ceph-chef::ceph-radosgw-webservice-install'

    # NB: May want to add a config file to hold admin user and keys etc.

    # Add nginx directory for app
    # Setup the NGINX config file. Since this is the only service using nginx we can just modify the nginx.conf directly.
    template '/etc/nginx/nginx.conf' do
        source 'nginx.conf.erb'
        owner 'root'
        group 'root'
        # notifies :reload, "service[nginx]", :immediately
    end

    # NB: So rgw_webservice process can read ceph.conf
    execute "add_user_to_ceph" do
      command "usermod -a -G ceph nginx"
      ignore_failure true
    end

    execute "add_nginx_to_radosgw" do
      command "usermod -a -G #{node['ceph']['radosgw']['rgw_webservice']['user']} nginx"
      ignore_failure true
    end

    # NB: Make sure the permissions of groups are set before the services are started later...
    include_recipe 'cepheus::user-groups'
end
