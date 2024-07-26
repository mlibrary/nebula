# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::prometheus::exporter::webserver::vhost (
  Boolean $testing = false
) {
  if $testing {
    include apache
  }

  apache::vhost { "prometheus-webserver-exporter":
    port     => "9180",
    docroot  => "/usr/local/lib/prom_web_exporter",
    aliases  => [{ scriptalias => "/", path => "/usr/local/lib/prom_web_exporter/" }],
    rewrites => [{ rewrite_rule => ["^/$ /metrics [last,redirect=permanent]"]}],
  }
}
