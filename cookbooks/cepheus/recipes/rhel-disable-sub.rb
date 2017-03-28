#
# Author:: Chris Jones <chris.jones@lambdastack.io>
# Cookbook Name:: cepheus
#
# Copyright 2017, LambdaStack
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
# This recipe disables the rhel subscription repo. You would use this if you were doing a repo_mirror on the
# bootstrap node instead of using Satellite/Capsule server for yum updates etc.

if node['cepheus']['pxe_boot']['os']['breed'] == 'redhat' && node['cepheus']['pxe_boot']['repo_mirror']
  execute 'rhel-disable-repo' do
    command 'subscription-manager config --rhsm.manage_repos=0'
  end
end