# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::role::gateway::primary {
  include nebula::role::minimal_docker

  include nebula::profile::consul::agent
  include nebula::profile::nat_router
  include nebula::profile::keepalived::primary

  $token = lookup('nebula::profile::consul::service_tokens')['web']

  service { 'consul': }

  docker::run { 'fake-service':
    image => 'nicholasjackson/fake-service:v0.7.8',
    ports => '9090:9090',
    env   => ['LISTEN_ADDR=0.0.0.0:9090', 'NAME=web', 'MESSAGE=Hello I am a website', 'UPSTREAM_URIS=http://localhost:9091'],
  }

  file { '/etc/consul.d/connect-web.json':
    notify  => Service['consul'],
    content => @("SERVICE_EOF")
      {
        "service": {
          "name": "web",
          "port": 9090,
          "token": "${token}",
          "check": {
            "id": "web-check",
            "http": "http://localhost:9090/health",
            "method": "GET",
            "interval": "1s",
            "timeout": "1s"
          },
          "connect": {
            "sidecar_service": {
              "proxy": {
                "upstreams": [{
                  "destination_name": "api-v1",
                  "local_bind_port": 9091
                }]
              }
            }
          }
        }
      }
      | SERVICE_EOF
  }
}
