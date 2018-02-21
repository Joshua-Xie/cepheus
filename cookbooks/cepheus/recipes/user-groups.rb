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

# PURPOSE:
# This recipe installs packages which are useful for debugging the stack
# and troubleshooting system issues. Packages should not be included here
# if the stack itself depends on them for its normal operation.

# The recipe also sets up security on ALL nodes AND initial Users!
# The recipe also adds the PS1 prompt change for all nodes!

# NB: Ceph will install the 'ceph' user and group each time a ceph component is installed. For example,
# If ceph mon has been installed on a node then you add your base user to the ceph group so that sudo is not required
# and then you happen to install ceph osd on the same node then the ceph group changes you made do not seem
# to remain and thus must be added again. This is why this recipe is called after every ceph related install.

# Add groups to a given user. If that user does not exist then it fail which is ok.
node['cepheus']['users'].each do | user_value |
  user_value['groups'].each do | user_value_group |
    if !user_value_group.empty?
      bash 'add-user-to-group' do
        user 'root'
        code <<-EOH
          usermod -a -G #{user_value['name']} #{user_value_group}
        EOH
        only_if "id -u #{user_value['name']}"
        only_if "grep -q #{user_value_group} /etc/group"
        ignore_failure true
      end

    end
  end
end
