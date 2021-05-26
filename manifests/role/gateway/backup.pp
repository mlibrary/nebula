# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::role::gateway::backup {
  include nebula::role::minimal_docker

  include nebula::profile::consul::agent
  include nebula::profile::nat_router
  include nebula::profile::keepalived::backup

  $token = lookup('nebula::profile::consul::service_tokens')['api-v1']

  service { 'consul': }

  docker::run { 'fake-service':
    image => 'nicholasjackson/fake-service:v0.7.8',
    ports => '9090:9090',
    env   => ['LISTEN_ADDR=0.0.0.0:9090', 'NAME=api-v1', 'MESSAGE=Response from API v1'],
  }

  file { '/etc/consul.d/connect-api-v1.json':
    notify  => Service['consul'],
    content => @("SERVICE_EOF")
      {
        "service": {
          "name": "api-v1",
          "port": 9090,
          "token": "${token}",
          "check": {
            "id": "api-v1-check",
            "http": "http://localhost:9090/health",
            "method": "GET",
            "interval": "1s",
            "timeout": "1s"
          },
          "connect": {
            "sidecar_service": {}
          }
        }
      }
      | SERVICE_EOF
  }
}
