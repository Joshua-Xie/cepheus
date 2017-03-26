#!/bin/bash
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

# NOTE: AUTOGENERATED FILE. Only modify template version.

# Exit immediately if anything goes wrong!
set -eu

# Creates the REPO_ROOT env var for everything else to use...
export REPO_ROOT=$(git rev-parse --show-toplevel)

# Builds the bootstrapping environment based on the templates and data found in this directory.

# NB: Output directories for this process already exists

# Build from template

echo "===> Generating bootstrap/vms/base_environment.sh..."
$REPO_ROOT/data/templates/jinja_render.py -d $REPO_ROOT/data/build.yaml -i $REPO_ROOT/data/templates/bootstrap/vms/base_environment.sh.j2 -o $REPO_ROOT/bootstrap/vms/base_environment.sh
sudo chmod +x $REPO_ROOT/bootstrap/vms/base_environment.sh

echo "===> Generating bootstrap/common/bootstrap_validate_env.sh..."
$REPO_ROOT/data/templates/jinja_render.py -d $REPO_ROOT/data/build.yaml -i $REPO_ROOT/data/templates/bootstrap/common/bootstrap_validate_env.sh.j2 -o $REPO_ROOT/bootstrap/common/bootstrap_validate_env.sh
sudo chmod +x $REPO_ROOT/bootstrap/common/bootstrap_validate_env.sh

echo "===> Generating bootstrap/common/bootstrap_prereqs.sh..."
$REPO_ROOT/data/templates/jinja_render.py -d $REPO_ROOT/data/build.yaml -i $REPO_ROOT/data/templates/bootstrap/common/bootstrap_prereqs.sh.j2 -o $REPO_ROOT/bootstrap/common/bootstrap_prereqs.sh
sudo chmod +x $REPO_ROOT/bootstrap/common/bootstrap_prereqs.sh