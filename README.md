# Blue-ONAP OpenDaylight

[![GitHub Tag][gh-tag-badge]]()
[![Docker Automated Build][dockerhub-badge]][dockerhub]

## Overview

This project generates a docker image of the
[OpenDaylight controller](https://www.opendaylight.org/what-we-do/current-release/sodium), and publishes it at [Docker Hub][dockerhub].

This distribution provides the following enhancements:

* The `fabric8-karaf-checks` feature is installed and exposes the `/readines-check` and `/health-check` endpoints. See [Fabric8 Karaf Health Checks][karaf-checks] for more information;
* You can use the `KARAF_FEATURES_BOOT` environment variable to specify additional features to be installed at start-up.

[dockerhub]:                  https://hub.docker.com/r/blueonap/opendaylight/
[dockerhub-badge]:            https://img.shields.io/docker/cloud/automated/blueonap/opendaylight
[gh-tag-badge]:               https://img.shields.io/github/v/tag/blue-onap/opendaylight?label=Release
[karaf-checks]:               https://fabric8.io/guide/karaf.html#fabric8-karaf-health-checks
