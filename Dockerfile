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

FROM adoptopenjdk/openjdk11:alpine-jre as stage0
RUN apk upgrade --no-cache -a

# Squash previous stage
FROM scratch
LABEL authors="eliezio.oliveira@est.tech"

COPY --from=stage0 / /

ARG odl_version=0.12.0
# SHA1 extracted from:
# https://nexus.opendaylight.org/content/repositories/public/org/opendaylight/integration/opendaylight/${odl_version}/opendaylight-${odl_version}.tar.gz.sha1
ARG odl_sha1=c9e4aaf31b76f862d6eba11c1928a2ce7610120d
ARG user=karaf
ARG group=karaf

ENV HOME=/opt/opendaylight

# Create a group and user
RUN set -eux; \
    addgroup $group; \
    adduser --home $HOME --no-create-home --ingroup $group --disabled-password $user

RUN set -eux; \
    archive_basename=opendaylight-${odl_version}; \
    archive_fullname=$archive_basename.tar.gz; \
    wget https://nexus.opendaylight.org/content/repositories/public/org/opendaylight/integration/opendaylight/${odl_version}/$archive_fullname; \
    echo "$odl_sha1  $archive_fullname" | sha1sum -cs; \
    tar xzf $archive_fullname; \
    rm $archive_fullname; \
    sed -i.orig $archive_basename/etc/org.apache.karaf.features.cfg \
      -e 's/^\(featuresRepositories\) *= *\(.*\)$/\1 = \2,\\\n  file:\${karaf.etc}\/4c3edce7-5493-4cf1-9ad2-5f054e889a28.xml,\\\n  \${karaf.features.repositories}/' \
      -e 's/^\(featuresBoot\) *= *\(.*\)$/\1 = \2,\\\n  3b0c66bc-9afc-429f-9dda-884da9f86221,\\\n  \${karaf.features.boot}/'; \
    sed -i.orig $archive_basename/bin/karaf \
      -e 's/^\( *\)\(-Dkaraf.etc="\${KARAF_ETC}"\)\( *\\\)$/\1\2\3\n\1-Dkaraf.features.repositories="\${KARAF_FEATURES_REPOSITORIES}"\3\n\1-Dkaraf.features.boot="\${KARAF_FEATURES_BOOT}"\3/'; \
    mv $archive_basename $HOME; \
    chown -R karaf:karaf $HOME

COPY etc/ $HOME/etc/

RUN mkdir -p $HOME/.m2
COPY settings.xml $HOME/.m2

# Tell docker that all future commands should run as the karaf user
USER $user
WORKDIR $HOME

#
# Mutable data files
# ==================
#
# data/*
# cache/*
# journal/*
# snapshots/*
# configuration/factory/*
# configuration/initial/*
# configuration/ssl/*
# etc/opendaylight/*
# etc/netconf.cfg
# etc/org.ops4j.pax.url.war.cfg
# etc/org.jolokia.osgi.cfg
# etc/org.opendaylight.aaa.filterchain.cfg
# etc/org.opendaylight.controller.cluster.datastore.cfg

# Karaf SSH shell port
EXPOSE 8101

# Java RMI
EXPOSE 1099 44444

# Web UI and MD-SAL RESTCONF
EXPOSE 8181

ENTRYPOINT $HOME/bin/karaf run
