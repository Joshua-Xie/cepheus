#
# Author: Chris Jones <chris.jones@lambdastack.io>
# Cookbook: cepheus
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

include_recipe 'cepheus::ceph-conf'

# include_recipe 'ceph-chef::erasure_profiles_set'

# NB: Use our version instead of ceph-chef's version!
node['cepheus']['ceph']['pools']['erasure_coding']['profiles'].each do |profile|
    execute "ec-pool-action-#{profile['profile']}" do
      command lazy { "ceph osd erasure-code-profile set #{profile['profile']} technique=#{profile['technique']} ruleset-root=#{profile['ruleset_root']} ruleset-failure-domain=#{profile['ruleset_failure_domain']} k=#{profile['key_value']['k']} m=#{profile['key_value']['m']}" }
      not_if "ceph osd erasure-code-profile get #{profile['profile']}"
    end
end
