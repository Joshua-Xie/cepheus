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

include_recipe 'cepheus::ceph-conf'

if node['cepheus']['method'] == 'pxe'
    # NOTE: May want to move mount and import to install later...
    # cobbler distro edit --name=#{node['cepheus']['pxe_boot']['os']['name']}-#{node['cepheus']['pxe_boot']['os']['arch']} --kopts="ksdevice= inst.repo=http://#{node['cepheus']['pxe_boot']['server']}/cblr/ks_mirror/#{node['cepheus']['pxe_boot']['os']['name']}"

    bash 'import-distro-distribution-pxe_boot' do
      user 'root'
      code <<-EOH
        mount -o loop /tmp/#{node['cepheus']['pxe_boot']['os']['distro']} /mnt
        cobbler import --name=#{node['cepheus']['pxe_boot']['os']['name']} --path=/mnt --breed=#{node['cepheus']['pxe_boot']['os']['breed']} --arch=#{node['cepheus']['pxe_boot']['os']['arch']}
        cobbler distro edit --name=#{node['cepheus']['pxe_boot']['os']['name']}-#{node['cepheus']['pxe_boot']['os']['arch']} --kopts="ksdevice= inst.repo=http://#{node['cepheus']['pxe_boot']['server']}/cblr/ks_mirror/#{node['cepheus']['pxe_boot']['os']['name']}-#{node['cepheus']['pxe_boot']['os']['arch']}"
        umount /mnt
      EOH
      not_if "cobbler distro list | grep #{node['cepheus']['pxe_boot']['os']['name']}"
      only_if "test -f /tmp/#{node['cepheus']['pxe_boot']['os']['distro']}"
    end

    # NOTE: By default, cobbler import above will create a profile with the name of the import + arch
    # Distro was added so no need to edit it.
    # Rename the profile to the FIRST profile in the data.
    # There MUST be 2 profiles in the data or this will fail

    # NOTE: Requirement for 2 profiles should be removed and specific args added to json file so that commands can simply be cycled through!!

    bash 'profile-update-pxe_boot' do
      user 'root'
      code <<-EOH
        cobbler profile edit --name=#{node['cepheus']['pxe_boot']['os']['name']}-#{node['cepheus']['pxe_boot']['os']['arch']} --kickstart=/var/lib/pxe_boot/kickstarts/#{node['cepheus']['pxe_boot']['kickstart']['file']["#{node['cepheus']['pxe_boot']['profiles'][0]['file_type']}"]} --kopts="interface=auto"
        cobbler profile rename --name=#{node['cepheus']['pxe_boot']['os']['name']}-#{node['cepheus']['pxe_boot']['os']['arch']} --newname=#{node['cepheus']['pxe_boot']['profiles'][0]['name']}
        cobbler profile edit --name=#{node['cepheus']['pxe_boot']['profiles'][0]['name']} --netboot-enabled=true --comment="#{node['cepheus']['pxe_boot']['profiles'][0]['comment']}" --name-servers="#{node['cepheus']['dns']['servers'].join(' ')}"
        cobbler profile copy --name=#{node['cepheus']['pxe_boot']['profiles'][0]['name']} --newname=#{node['cepheus']['pxe_boot']['profiles'][1]['name']}
        cobbler profile edit --name=#{node['cepheus']['pxe_boot']['profiles'][1]['name']} --kickstart=/var/lib/pxe_boot/kickstarts/#{node['cepheus']['pxe_boot']['kickstart']['file']["#{node['cepheus']['pxe_boot']['profiles'][1]['file_type']}"]}
      EOH
      only_if "cobbler profile list"
      only_if "test -f /tmp/#{node['cepheus']['pxe_boot']['os']['distro']}"
    end

    # Update the Red Hat Satellite/Capsule/RHN info
    if node['cepheus']['pxe_boot']['os']['breed'] == 'redhat' && node['cepheus']['pxe_boot']['redhat']['management']['type']
      bash 'pxe_boot-rhel-mgt' do
        user 'root'
        code <<-EOH
          cobbler profile edit --name=#{node['cepheus']['pxe_boot']['profiles'][0]['name']} --redhat-management-key=#{node['cepheus']['pxe_boot']['redhat']['management']['key']} --redhat-management-server=#{node['cepheus']['pxe_boot']['redhat']['management']['server']}
          cobbler profile edit --name=#{node['cepheus']['pxe_boot']['profiles'][1]['name']} --redhat-management-key=#{node['cepheus']['pxe_boot']['redhat']['management']['key']} --redhat-management-server=#{node['cepheus']['pxe_boot']['redhat']['management']['server']}
        EOH
        only_if "test -f /tmp/#{node['cepheus']['pxe_boot']['os']['distro']}"
      end
    end

    # Set up a default system - you will need to add the information via cobbler system edit on the cli to match your environment
    # Also, do cobbler system add for every ceph node with mac, IP, etc OR modify the json data used by cobbler and then restart cobbler
    node['cepheus']['servers'].each do | server |
      if !server.roles.include? 'bootstrap'
        # NOTE: Set cluster gateway to "" - #{server['network']['cluster']['gateway']}

        # NOTE: IMPORTANT - Add commands to template and have this file dynamically built to support the correct data!!!!!

        bash 'add-to-pxe_boot' do
          user 'root'
          code <<-EOH
            cobbler system add --name=#{server['name']} --profile=#{server['profile']} --static=true --interface=#{server['network']['public']['interface']} --mac=#{server['network']['public']['mac']} --ip-address=#{server['network']['public']['ip']} --netmask=#{server['network']['public']['netmask']} --if-gateway=#{server['network']['public']['gateway']} --hostname=#{server['name']} --mtu=#{server['network']['public']['mtu']}
            cobbler system edit --name=#{server['name']} --static=true --interface=#{server['network']['cluster']['interface']} --mac=#{server['network']['cluster']['mac']} --ip-address=#{server['network']['cluster']['ip']} --netmask=#{server['network']['cluster']['netmask']} --if-gateway="" --mtu=#{server['network']['cluster']['mtu']}
          EOH
          not_if "cobbler system list | grep #{server['name']}"
          only_if "cobbler profile list | grep #{server['profile']}"
          #only_if "test -f /tmp/#{node['cepheus']['pxe_boot']['os']['distro']}"
        end
      end
    end

    # Update mac addresses - PUBLIC and CLUSTER
    # May want to add interfaces as an array so that any number of nic/mac can be added
    # TODO: Also update for any bonded nics
    node['cepheus']['pxe_boot']['servers'].each do | server |
      # IMPORTANT: his version sets the --if-gateway of the cluster interface to "" so that ARP does not cause a race condition!
      bash 'update-pxe_boot-macs1' do
        user 'root'
        code <<-EOH
          cobbler system edit --name=#{server['name']} --static=true --interface=#{server['network']['public']['interface']} --mac=#{server['network']['public']['mac']} --ip-address=#{server['network']['public']['ip']} --netmask=#{server['network']['cluster']['netmask']} --if-gateway=#{server['network']['public']['gateway']} --mtu=#{server['network']['public']['mtu']}
          cobbler system edit --name=#{server['name']} --static=true --interface=#{server['network']['cluster']['interface']} --mac=#{server['network']['cluster']['mac']} --ip-address=#{server['network']['cluster']['ip']} --netmask=#{server['network']['cluster']['netmask']} --if-gateway="" --mtu=#{server['network']['cluster']['mtu']}
        EOH
        only_if "cobbler system list | grep #{server['name']}"
      end
    end

    # Cobbler will create the base pxe boot files needed. Every time you modify profile/system/distro you will need to do a pxe_boot sync
    execute 'pxe_boot-sync' do
      command lazy{ "cobbler sync" }
      only_if "test -f /tmp/#{node['cepheus']['pxe_boot']['os']['distro']}"
    end

    # The block below is done for non-vagrant environments
    if node['cepheus']['environment'] != 'vagrant'
      # NOTE: The items below can fail but also means it will have to be updated manually. This
      # NOTE: The /tmp/postinstall must exist
      execute 'tar-postinstall' do
        command lazy { "tar -zcvf /var/www/cobbler/pub/postinstall.tar.gz /tmp/postinstall/" }
        not_if "test -f /var/www/cobbler/pub/postinstall.tar.gz"
        # ignore_failure true
      end

      # Get the validate.pem and install client.rb into /var/www/cobbler/pub
      bash 'copy-chef-node' do
        user 'root'
        code <<-EOH
          sudo cp /etc/opscode/cepheus-validator.pem /var/www/cobbler/pub/validation.pem
          sudo chmod 0644 /var/www/cobbler/pub/validation.pem
        EOH
        # ignore_failure true
      end

      template '/var/www/cobbler/pub/client.rb' do
        source 'client.rb.erb'
        mode '0644'
        # ignore_failure true
      end

      # NOTE: The kickstart process creates the directores, wgets the files to the node's /etc/chef and sets the permissions.
      # It then runs chef-client to verify
    end
end
