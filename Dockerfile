FROM openjdk:8-jre-alpine
LABEL authors="eliezio.oliveira@est.tech"

ARG odl_version=0.11.0
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

# Tell docker that all future commands should run as the karaf user
USER $user

EXPOSE 8101 1099 44444 8181

ENTRYPOINT $HOME/bin/karaf run
