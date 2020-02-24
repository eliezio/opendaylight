# Blue-ONAP OpenDaylight

[![GitHub Tag][gh-tag-badge]]()
[![Docker Automated Build][dockerhub-badge]][dockerhub]

## Overview

This project generates a docker image of the
[OpenDaylight controller](https://www.opendaylight.org/what-we-do/current-release/sodium), and publishes it at [Docker Hub][dockerhub].

This distribution provides the following enhancements:

* The `fabric8-karaf-checks` feature is installed and exposes the `/readiness-check` and `/health-check` endpoints. See [Fabric8 Karaf Health Checks][karaf-checks] for more information;
* You can add more feature repositories and features by defining two environment variables:

| Environment Variable | Purpose
| -------------------- | -------
| `KARAF_FEATURES_REPOSITORIES` | Configure additional feature repositories.
| `KARAF_FEATURES_BOOT` | Use to specify additional features to be installed and activated at start-up.

## Usage Examples

### Run OpenDaylight ready to connect to Netopeer2-based servers

#### Step 1: Launches OpenDaylight

Two additional features are required: `odl-restconf-all` and `odl-netconf-topology`.

```shell script
$ docker run -d -p 8181:8181 \
  -e KARAF_FEATURES_BOOT=odl-restconf-all,odl-netconf-topology \
  quay.io/blue-onap/opendaylight:v0.11.2-3
```

#### Step 2: Configure TLS to connect to Netopeer2

Using the files from the directory [./config](https://github.com/blue-onap/opendaylight/tree/master/config),
you need to run a single command to apply the compatible configuration:

```shell script
$ ./odl-setup-ks.sh
```

[dockerhub]:                  https://hub.docker.com/r/blueonap/opendaylight/
[dockerhub-badge]:            https://img.shields.io/docker/cloud/automated/blueonap/opendaylight
[gh-tag-badge]:               https://img.shields.io/github/v/tag/blue-onap/opendaylight?label=Release
[karaf-checks]:               https://fabric8.io/guide/karaf.html#fabric8-karaf-health-checks
