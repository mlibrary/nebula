# Copyright (c) 2018-2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::networking::firewall
#
# Manage firewall (iptables) settings
#
# These are baseline/standard service provisions where specific ranges/values
# should be specified in hiera.
#
# @example
#   include nebula::profile::networking::firewall
class nebula::profile::networking::firewall (
  String $internal_routing = '',
  Hash $rules = {},
  Hash $advanced_rules = {},
) {
  # Include standard SSH rules by default
  include nebula::profile::networking::firewall::ssh

  ensure_packages(['netfilter-persistent','iptables-persistent'])

  package { 'lokkit':
    ensure => absent
  }

  if $internal_routing == '' {
    resources { 'firewall':
      purge => true,
    }

    firewallchain {
      ['INPUT:filter:IPv4', 'OUTPUT:filter:IPv4', 'FORWARD:filter:IPv4',
      'INPUT:filter:IPv6', 'OUTPUT:filter:IPv6', 'FORWARD:filter:IPv6']:
        ensure => 'present',
        policy => 'accept',
      ;
    }
  } else {
    case $internal_routing {
      'docker': {
        $input_ignore = [
        ]

        $output_ignore = [
          '-j DOCKER',
        ]

        case $::os['name'] {
          default: {
            $forward_ignore = []
          }

          'Debian': {
            $forward_ignore = [
              '-j DOCKER-USER',
              '-j DOCKER-ISOLATION',
              '-i docker0',
              '-o docker0',
            ]
          }

          'Ubuntu': {
            $forward_ignore = [
              '-j DOCKER-USER',
              '-j DOCKER-ISOLATION',
              '-i docker0',
              '-o docker0',
              '-i br-',
              '-o br-',
            ]
          }
        }
      }

      'kubernetes_calico': {
        $input_ignore = [
          '-j cali-INPUT',
          '-j KUBE-FIREWALL',
          '-j KUBE-SERVICES',
          '-j KUBE-EXTERNAL-SERVICES',
        ]

        $output_ignore = [
          '-j cali-OUTPUT',
          '-j KUBE-FIREWALL',
          '-j KUBE-SERVICES',
        ]

        $forward_ignore = [
          '-j cali-FORWARD',
          '-j KUBE-FORWARD',
          '-j KUBE-SERVICES',
        ]
      }

      'fwknop': {
        $input_ignore = ['-j FWKNOP_INPUT']
        $output_ignore = []
        $forward_ignore = []
      }

      default: {
        $input_ignore = []
        $output_ignore = []
        $forward_ignore = []
      }
    }

    # todo: Revisit Kubernetes ignores when we treat IPv6.
    #
    firewallchain {
      default:
        ensure => 'present',
        purge  => true,
        policy => 'accept',
      ;

      'INPUT:filter:IPv4':
        ignore => $input_ignore,
      ;

      'OUTPUT:filter:IPv4':
        ignore => $output_ignore,
      ;

      'FORWARD:filter:IPv4':
        ignore => $forward_ignore,
      ;

      'INPUT:filter:IPv6':
      ;

      'FORWARD:filter:IPv6':
      ;

      'OUTPUT:filter:IPv6':
      ;
    }

  }

  $firewall_defaults = {
    proto  => 'tcp',
    state  => 'NEW',
    action => 'accept'
  }

  create_resources(firewall,$rules,$firewall_defaults)
  create_resources(firewall,$advanced_rules)

  # Default IPv4 items, sorted by title
  firewall { '001 accept related established rules':
    proto  => 'all',
    state  => ['RELATED', 'ESTABLISHED'],
    action => 'accept',
  }

  firewall { '001 accept all to lo interface':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
  }

  firewall { '999 drop all':
    proto  => 'all',
    action => 'drop',
    before => undef,
  }

  # Default IPv6 items, sorted by title
  firewall { '001 accept related established rules (v6)':
    proto    => 'all',
    state    => ['RELATED', 'ESTABLISHED'],
    action   => 'accept',
    provider => 'ip6tables',
  }

  firewall { '001 accept all to lo interface (v6)':
    proto    => 'all',
    iniface  => 'lo',
    action   => 'accept',
    provider => 'ip6tables',
  }

  firewall { '999 drop all (v6)':
    proto    => 'all',
    action   => 'drop',
    before   => undef,
    provider => 'ip6tables',
  }

}
