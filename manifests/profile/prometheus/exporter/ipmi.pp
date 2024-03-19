# Copyright (c) 2023 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::prometheus::exporter::ipmi (
  Hash[String, Hash] $accounts = {}
) {
  if $accounts != {} {
    include nebula::profile::kubelet

    file { "/etc/kubernetes/manifests/ipmi_exporter.yaml":
      content => template("nebula/profile/prometheus/exporter/ipmi/pod.yaml.erb")
    }

    file { "/etc/prometheus":
      ensure => "directory"
    }

    file { "/etc/prometheus/ipmi.yaml":
      content => template("nebula/profile/prometheus/exporter/ipmi/config.yaml.erb")
    }

    nebula::discovery::listen_on_port { "prometheus_ipmi_${::datacenter}":
      concat_target  => "/etc/prometheus/ipmi.yml",
      concat_order   => "02",
      concat_content => template("nebula/profile/prometheus/exporter/ipmi/scrape_config.yaml.erb")
    }
  }
}
