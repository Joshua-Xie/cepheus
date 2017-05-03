#!/bin/bash
#
# Author:: Chris Jones <chris.jones@lambdastack.io>
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

ceph osd getcrushmap -o /tmp/tmp.out
crushtool -d /tmp/tmp.out -o /tmp/tmp.txt
sed -i -e 's/alg straw/alg straw2/g' /tmp/tmp.txt
# Just in case...
sed -i -e 's/alg straw22/alg straw2/g' /tmp/tmp.txt
crushtool -c /tmp/tmp.txt -o /tmp/tmp.out
ceph osd setcrushmap -i /tmp/tmp.out

# NB: This process gets the crushmap (after it has been updated by the OSDs) and makes sure the 'alg straw2' algorithim
# is being used instead of the default 'alg straw'.
