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

if node['cepheus']['adc']['keepalived']['enable']
    package 'keepalived' do
      action :upgrade
    end

    # Installs killall
    package 'psmisc'

    # Set the config
    # NOTE: If the virtual_router_id is
    template "/etc/keepalived/keepalived.conf" do
      source 'keepalived.conf.erb'
      variables lazy {
        {
          :adc_nodes => adc_nodes,
          :server => get_keepalived_server
        }
      }
    end

    if node['cepheus']['init_style'] == 'upstart'
    else
      # Broke out the service resources for better idempotency.
      service 'keepalived-enable' do
        service_name 'keepalived'
        action [:enable]
        only_if "sudo systemctl status keepalived | grep disabled"
      end

      service 'keepalived-start' do
        service_name 'keepalived'
        action [:start]
        supports :restart => true, :status => true
        subscribes :restart, "template[/etc/keepalived/keepalived.conf]"
      end
    end
end
