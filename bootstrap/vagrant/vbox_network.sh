#!/bin/bash
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

# Exit immediately if anything goes wrong, instead of making things worse.

# IMPORTANT: Cobbler system ... are configured with network info so no need for this file except for vagrant and
# to build the bootstrap node for vbox.

set -e

function node_update_network_interfaces {
  set +e
  # Step 1
  node_remove_default_network_connections
  # Step 2
  node_remove_new_network_connections
  # Step 3
  node_add_network_connections
  set -e
}

function node_modify_network_interfaces {
  IFS_OLD=$IFS
  IFS=$'\n'
  ifaces=($(sudo nmcli -t -f NAME,UUID,DEVICE c s))
  for ifs in ${ifaces[@]}; do
    _name=$(echo $ifs | awk -F: '{print $1}')
    _uuid=$(echo $ifs | awk -F: '{print $2}')
    _device=$(echo $ifs | awk -F: '{print $3}')
    echo $_name
    echo $_uuid
    echo $_device
    # You could also delete the connections and then add new ones
    # if [[ $_device == "enp0s8" || ($_device == "--" && $_name == "Wired connection 1") ]]; then
    #    sudo nmcli c modify $_uuid connection.id 'mgt-enp0s8'
    # fi
    if [[ $_device == "eth1" || ($_device == "--" && $_name == "Wired connection 1") ]]; then
        sudo nmcli c modify $_uuid connection.id 'eth1'
    fi
    if [[ $_device == "eth2" || ($_device == "--" && $_name == "Wired connection 2") ]]; then
        sudo nmcli c modify $_uuid connection.id 'eth2'
    fi
  done
  IFS=$IFS_OLD
}

function node_update_network_ips {
  # You can add ipv6 if you like...
  # Set each interface IP, bring it up and set dns (google dns in this case - change it whatever you want or leave it :))
  # sudo nmcli c mod mgt-enp0s8 ipv4.addresses ${CEPH_ADAPTER_IPS[0]}/${CEPH_ADAPTER_IPS[3]} ipv4.gateway ${CEPH_ADAPTER_IPS[4]}
  # sudo nmcli c mod mgt-enp0s8 ipv4.method manual
  # sudo nmcli c mod mgt-enp0s8 ipv4.dns "8.8.8.8 8.8.4.4"

  sudo nmcli c mod eth1 ipv4.addresses ${CEPH_ADAPTER_IPS[0]}/${CEPH_ADAPTER_IPS[2]} ipv4.gateway ${CEPH_ADAPTER_IPS[3]}
  sudo nmcli c mod eth1 ipv4.method manual
  sudo nmcli c mod eth1 ipv4.dns "${CEPH_CHEF_DNS[0]} ${CEPH_CHEF_DNS[1]}"

  sudo nmcli c mod eth2 ipv4.addresses ${CEPH_ADAPTER_IPS[1]}/${CEPH_ADAPTER_IPS[2]} ipv4.gateway ${CEPH_ADAPTER_IPS[4]}
  sudo nmcli c mod eth2 ipv4.method manual
  sudo nmcli c mod eth2 ipv4.dns "${CEPH_CHEF_DNS[0]} ${CEPH_CHEF_DNS[1]}"

  # sudo nmcli c up mgt-enp0s8
  sudo nmcli c up eth1
  sudo nmcli c up eth2
}

# Step 1
function node_remove_default_network_connections {
  sudo nmcli con delete 'Wired connection 1'
  sudo nmcli con delete 'Wired connection 2'
}

# Step 2
function node_remove_new_network_connections {
  sudo nmcli con delete eth1
  sudo nmcli con delete eth2
}

# Step 3
function node_add_network_connections {
  sudo nmcli con add type ethernet con-name eth1 ifname eth1
  sudo nmcli con add type ethernet con-name eth2 ifname eth2
}