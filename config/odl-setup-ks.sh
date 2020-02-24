#!/bin/bash

# ============LICENSE_START=======================================================
#  Copyright (C) 2020 Nordix Foundation.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END=========================================================

SCRIPT_PATH=$(dirname $(realpath -s $0))

ODL_URL=http://localhost:8181

while true; do
    if http --check-status $ODL_URL/readiness-check &> /dev/null; then
        break
    fi
    echo Waiting for OpenDaylight to be ready
    sleep 2
done

set -euo pipefail

USER=admin
PASSWORD=admin

RESTCONF_URL=$ODL_URL/restconf
sess=.session

http --auth $USER:$PASSWORD --session=$sess --print Hh DELETE $RESTCONF_URL/config/netconf-keystore:keystore
for json in $SCRIPT_PATH/??_ks_*.json; do
    http --check-status --session=$sess --print Hh POST $RESTCONF_URL/config/netconf-keystore:keystore < $json
done
