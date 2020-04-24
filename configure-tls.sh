#!/bin/ash

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

set -o errexit
set -o pipefail
set -o nounset
[ "${SHELL_XTRACE:-false}" = "true" ] && set -o xtrace

# Overridable environment variables
# ---------------------------------

CONFIG=${CONFIG:-/config/tls}
ODL_URL=${ODL_URL:-http://localhost:8181}
ODL_USERNAME=${ODL_USERNAME:-admin}
ODL_PASSWORD=${ODL_USERNAME:-admin}

PROC_NAME=${0##*/}
PROC_NAME=${PROC_NAME%.sh}

function now_ms() {
    # Requires coreutils package
    date +"%Y-%m-%d %H:%M:%S.%3N"
}

function log() {
    local level=$1
    shift
    local message="$*"
    printf "%s %-5s [%s] %s\n" "$(now_ms)" $level $PROC_NAME "$message"
}

while true; do
    sc=$(curl -s -o /dev/null -w %{http_code} $ODL_URL/readiness-check || true)
    if [ "$sc" = "200" ]; then
        break
    fi
    if [ "$sc" != "000" -a "$sc" != "503" ]; then
        log ERROR Readiness-check failed with SC=$sc
        exit 1
    fi
    log INFO Waiting for OpenDaylight to be ready \(SC=$sc\)
    sleep 2
done

# Extracts the body of a PEM file by removing the dashed header and footer
pem_body() {
    grep -Fv -- ----- $1
}

CA_CERT_ID=xNF_CA_certificate_0_0
CA_CERT=$(pem_body $CONFIG/ca.pem)

CLIENT_PRIV_KEY_ID=ODL_private_key_0
CLIENT_KEY=$(pem_body $CONFIG/client_key.pem)
CLIENT_CERT=$(pem_body $CONFIG/client_cert.pem)

RESTCONF_URL=$ODL_URL/restconf
NETCONF_KEYSTORE_PATH=$RESTCONF_URL/config/netconf-keystore:keystore

xcurl() {
    curl -s -o /dev/null -w %{http_code} --user $ODL_USERNAME:$ODL_PASSWORD "$@"
}

log INFO Delete Keystore
sc=$(xcurl -X DELETE $NETCONF_KEYSTORE_PATH)

if [ "$sc" != "200" -a "$sc" != "404" ]; then
    log ERROR "Keystore deletion failed with SC=$sc"
    exit 1
fi

log INFO Load CA certificate
sc=$(xcurl -X POST $NETCONF_KEYSTORE_PATH --header "Content-Type: application/json" --data "
{
  \"trusted-certificate\": [
    {
      \"name\": \"$CA_CERT_ID\",
      \"certificate\": \"$CA_CERT\"
    }
  ]
}
")

if [ "$sc" != "200" -a "$sc" != "204" ]; then
    log ERROR Trusted-certificate update failed with SC=$sc
    exit 1
fi

log INFO Load client private key and certificate
sc=$(xcurl -X POST $NETCONF_KEYSTORE_PATH --header "Content-Type: application/json" --data "
{
  \"private-key\": {
    \"name\": \"$CLIENT_PRIV_KEY_ID\",
    \"certificate-chain\": [
      \"$CLIENT_CERT\"
    ],
    \"data\": \"$CLIENT_KEY\"
  }
}
")

if [ "$sc" != "200" -a "$sc" != "204" ]; then
    log ERROR Private-key update failed with SC=$sc
    exit 1
fi
