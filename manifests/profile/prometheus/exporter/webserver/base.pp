# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::prometheus::exporter::webserver::base (
  Hash[String, Hash[String, String]] $mariadb_connect = {},
  Hash[String, Array[String]] $nfs_mounts = {},
  Hash[String, Array[String]] $solr_instances = {},
  Hash[String, Boolean] $check_shibd = {},
  String $target,
) {
  include stdlib
  $target_mariadb = pick_default($mariadb_connect[$target], {})
  $target_nfs = pick_default($nfs_mounts[$target], [])
  $target_solr = pick_default($solr_instances[$target], [])
  $target_shibd = pick_default($check_shibd[$target], false)

  file { "/usr/local/lib/prom_web_exporter/metrics":
    mode    => "0755",
    content => template("nebula/profile/prometheus/exporter/webserver/metrics.sh.erb"),
    require => File["/usr/local/lib/prom_web_exporter"],
  }

  file { "/usr/local/lib/prom_web_exporter":
    ensure => "directory",
  }

  if $target_mariadb != {} {
    package { "mariadb-client": }
  }
}
