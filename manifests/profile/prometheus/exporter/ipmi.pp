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

    # This looks awfully similar to, but not the same as, the code in
    # node.pp. Once mysql and haproxy exporters support public/private
    # ip addresses, I expect a shape will emerge. Some differences are
    # that, for ipmi exporters, I'm not supporting datacenters that lack
    # a dedicated prometheus server, plus I don't have to care about the
    # pushgateway script. I just need to open a port and export config.
    $all_public_addresses = $facts["mlibrary_ip_addresses"]["public"]
    $all_private_addresses = $facts["mlibrary_ip_addresses"]["private"]

    if $all_public_addresses == [] and $all_private_addresses == [] {
      fail("Host cannot be scraped without a public or private IP address")
    } elsif $all_private_addresses != [] {
      $ipaddress = $all_private_addresses[0]
      Firewall <<| tag == "${::datacenter}_prometheus_private_ipmi_exporter" |>>
    } else {
      $ipaddress = $all_public_addresses[0]
      Firewall <<| tag == "${::datacenter}_prometheus_public_ipmi_exporter" |>>
    }

    @@concat_fragment { "prometheus ipmi scrape config ${::hostname}":
      tag     => "${::datacenter}_prometheus_ipmi_exporter",
      target  => "/etc/prometheus/ipmi.yml",
      order   => "02",
      content => template("nebula/profile/prometheus/exporter/ipmi/scrape_config.yaml.erb")
    }
  }
}
