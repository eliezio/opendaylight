Blue-ONAP OpenDaylight
======================

.. sectnum::

.. _dockerhub: https://hub.docker.com/r/blueonap/opendaylight/
.. _karaf-checks: https://fabric8.io/guide/karaf.html#fabric8-karaf-health-checks

|release-badge| |docker-badge|

.. |release-badge| image:: https://img.shields.io/github/v/tag/blue-onap/opendaylight?label=Release
   :alt: GitHub tag
.. |docker-badge| image:: https://img.shields.io/badge/docker%20registry-Quay.io-red
   :target: https://quay.io/repository/blue-onap/opendaylight?tab=tags

Overview
--------

This project generates a docker image of the
`OpenDaylight Controller <https://www.opendaylight.org/what-we-do/current-release/magnesium>`_, and publishes it at `Docker Hub <dockerhub_>`_.

This distribution provides the following enhancements:

* The ``fabric8-karaf-checks`` feature is pre-installed and exposes the ``/readiness-check`` and ``/health-check`` endpoints. See `Fabric8 Karaf Health Checks <karaf-checks_>`_ for more information;
* You can add more feature repositories and features by defining two environment variables:

.. list-table::
   :widths: 20 40
   :header-rows: 1

   * - Environment Variable
     - Purpose
   * - ``KARAF_FEATURES_REPOSITORIES``
     - Configure additional feature repositories.
   * - ``KARAF_FEATURES_BOOT``
     - Use to specify additional features to be installed and activated at start-up.

Usage Examples
--------------

Run OpenDaylight ready to connect to Netopeer2-based servers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Step 1: Launches OpenDaylight
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Two additional features are required: ``odl-restconf-all`` and ``odl-netconf-connector-all``.

.. code:: shell

    $ docker run -d -p 8181:8181 \
      -e KARAF_FEATURES_BOOT=odl-restconf-all,odl-netconf-connector-all \
      quay.io/blue-onap/opendaylight:v0.12.0-2

Or using Docker Compose:

.. code:: yaml

    version: '3'

    services:
      opendaylight:
        image: quay.io/blue-onap/opendaylight:v0.12.0-2
        container_name: opendaylight
        ports:
          - "8101:8101"
          - "8181:8181"
          - "6666:6666"
        environment:
          - KARAF_FEATURES_BOOT=odl-restconf-all,odl-netconf-connector-all
        volumes:
          - ./config:/config

Step 2: Configure TLS to connect to Netopeer2
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You need to provide the following PEM files under ``./config/tls``:

.. list-table::
   :widths: 10 50
   :header-rows: 1

   * - File
     - Contents
   * - ``client_key.pem``
     - The client's private key in plain (*not* protected by a passphrase).
   * - ``client_cert.pem``
     - The corresponding client X.509v3 certificate.
   * - ``ca.pem``
     - The Certificate Authority (CA) certificate.

You can apply this configuration at runtime by running:

.. code:: shell

   $ docker exec <CONTAINER NAME or ID> /opt/bin/configure-tls.sh
