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
# This recipe installs packages which are useful for debugging the stack
# and troubleshooting system issues. Packages should not be included here
# if the stack itself depends on them for its normal operation.

# The recipe also sets up security on ALL nodes AND initial Users!
# The recipe also adds the PS1 prompt change for all nodes!

include_recipe 'cepheus::ceph-conf'

# Network troubleshooting tools
package 'ethtool'
package 'nmap'
package 'iperf'
package 'curl'
package 'bmon'
package 'socat'
package 'iftop'
# package 'conntrack'
package 'tmux'
package 'fping'
# Used to help find sensor issues on nodes if BMC doesn't show much
package 'lm_sensors'
package 'whois'

# Helps with checking OSD performance
package 'perf'

# I/O troubleshooting tools
package 'fio'
package 'bc'
package 'iotop'
package 'atop'

# System troubleshooting tools
package 'htop'
package 'sysstat'
package 'vim'
package 'patch'
package 'lshw'
package 'sg3_utils'
package 'sshpass'

# JSON parse
# package 'jp'

if node['cepheus']['init_style'] == 'upstart'
    package 'python-dev'
    package 'build-essential'
else
    # Yum versionlock - Check the yum-versionlock recipe for details...
    package 'yum-versionlock'
    package 'kexec-tools'
    package 'python2-boto3' do
        :upgrade
    end
end

package 'python-pip' do
    :upgrade
end
package 'python-boto' do
    :upgrade
end

# Copy the scripts to the nodes
remote_directory '/opt/cepheus/scripts' do
    source 'scripts'
    action :create
    owner node['cepheus']['chef']['owner']
    mode 0755
end

execute 'set-scripts-perm' do
    command "sudo chmod +x /opt/cepheus/scripts/*.sh"
end

# Default to bootstrap role
node_roles = []
if is_adc_node
    node_roles << 'adc'
end
if is_radosgw_node
    node_roles << 'rgw'
end
if is_mon_node
    node_roles << 'mon'
end
if is_osd_node
    node_roles << 'osd'
end

# Create user(s) if not already existing
node['cepheus']['users'].each do | user_value |
    create_user = false
    user_value['roles'].each do | user_role |
        if user_role == "all" || node_roles.include?(user_role)
            create_user = true
        end

        if create_user
            user user_value['name'] do
                comment user_value['comment']
                group user_value['group']
                shell user_value['shell']
                password user_value['passwd']
                system user_value['system']
                ignore_failure true
            end

            if user_value['group_create']
                group user_value['name'] do
                    members user_value['name']
                    ignore_failure true
                end
            end

            # Go ahead break the inner loop after creating user
            break
        end
    end
    # NB: Additional groups can not be added until everything has been setup to make sure the valid group exists!
end

template "/etc/profile.d/cepheus.sh" do
    source 'cepheus.sh.erb'
    ignore_failure true
end

# Add the scary MOTD to let people know it's production!!
template '/etc/motd' do
    source 'motd.tail.erb'
    mode 00644
end

# Set ntp servers
node.default['ntp']['servers'] = node['cepheus']['ntp']['servers']

# If you want a dev/test environment then make sure this is set to `true` in attributes/default
# NOTE: By default, if you set true in the environment json file it will override the default of false.
# This will also install the development environment on all ceph nodes in the cluster.
# If you only want it on mon nodes the move this code block to the ceph-mon.rb recipe file (just an example).
# I would not recommend doing this production unless you absolutely need to (keep the default of false).
if node['cepheus']['development']['enabled']
    include_recipe 'yumgroup::default'
    package 'git'
    package 'cmake'
    package 'openssl'
    # libssl in Ubuntu
    package 'openssl-devel'
    yumgroup 'Development Tools' do
        action :install
    end
    # NB: At the end of the ceph install, librados libraries will have been installed. Symlink them:
    # sudo ln -s /usr/lib64/librados.so.2.0.0 /usr/lib64/librados.so
    # This will allow some Ceph tools to find it easier.
    # There is a recipe called ceph-finish.rb that does this. In the Vagrant dev environment, it's done automatically.
end
