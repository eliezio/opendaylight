FROM openjdk:8-jre-alpine
LABEL authors="eliezio.oliveira@est.tech"

ARG odl_version=0.11.2
ARG user=karaf
ARG group=karaf

ENV HOME=/opt/opendaylight

# Create a group and user
RUN addgroup $group \
    && adduser --home $HOME --no-create-home --ingroup $group --disabled-password $user

RUN cd /opt && wget -q -O - https://nexus.opendaylight.org/content/repositories/public/org/opendaylight/integration/opendaylight/${odl_version}/opendaylight-${odl_version}.tar.gz \
    | tar xzf - \
    && mv opendaylight-${odl_version} $HOME \
    && chown -R karaf:karaf $HOME

RUN mkdir -p $HOME/.m2
COPY settings.xml $HOME/.m2

# Tell docker that all future commands should run as the karaf user
USER $user

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

EXPOSE 8101 1099 44444 8181

ENTRYPOINT $HOME/bin/karaf run

