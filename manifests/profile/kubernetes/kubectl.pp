# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::kubernetes::kubectl {
  $cluster_name = lookup('nebula::profile::kubernetes::cluster')
  $cluster = lookup('nebula::profile::kubernetes::clusters')[$cluster_name]
  $private_domain = $cluster['private_domain']
  $control_dns = $cluster['control_dns']
  $public_address = $cluster['public_address']
  $etcd_address = $cluster['etcd_address']
  $kube_api_address = $cluster['kube_api_address']
  $service_cidr = pick($cluster['service_cidr'], lookup('nebula::profile::kubernetes::service_cidr'))
  $kube_internal_ip = ip_from_cidr($service_cidr, 1)
  include nebula::profile::kubernetes::apt

  package { 'kubectl':
    require => Apt::Source['kubernetes'],
  }

  concat { '/var/local/generate_pki.sh': }

  Concat_fragment <<| tag == "${cluster_name}_pki_generation" |>>

  concat_fragment {
    default:
      target => '/var/local/generate_pki.sh',
    ;

    'cluster pki preamble':
      order   => '01',
      content => template('nebula/profile/kubernetes/bootstrap/keys_01_preamble.sh.erb'),
    ;

    'cluster pki functions':
      order   => '03',
      content => template('nebula/profile/kubernetes/bootstrap/keys_03_functions.sh.erb'),
    ;
  }
}
