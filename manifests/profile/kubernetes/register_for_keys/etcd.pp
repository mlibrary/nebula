# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::kubernetes::register_for_keys::etcd {
  $cluster_name = lookup('nebula::profile::kubernetes::cluster')

  @@concat_fragment { "cluster pki for ${::hostname}":
    tag     => "${cluster_name}_pki_generation",
    target  => '/var/local/generate_pki.sh',
    order   => '02',
    content => "ETCD_NODES=(\"\${ETCD_NODES[@]}\" \"${::hostname}/${::ipaddress}\")\n",
  }
}
