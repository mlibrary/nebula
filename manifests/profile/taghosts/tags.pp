# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::taghosts::tags (
  String $hiera_lookup = 'nebula::taghost::hiera',
) {
  Nebula::Taghosts::Tag <| |>

  lookup($hiera_lookup, default_value => []).each |$tag| {
    @nebula::taghosts::tag { $tag:
      order => '750',
    }
  }

  # Each line starts with the fqdn, a tab, and the tag "puppet" to show
  # this host's tags are managed by puppet.
  @@concat::fragment { "taghosts ${facts['fqdn']} 000":
    tag     => 'taghosts',
    target  => '/var/lib/ae/active-servers',
    content => "${facts['fqdn']}\tpuppet",
  }

  # Each line ends with a newline.
  @@concat::fragment { "taghosts ${facts['fqdn']} 999":
    tag     => 'taghosts',
    target  => '/var/lib/ae/active-servers',
    content => "\n",
  }

  $datacenter_tag = $facts['datacenter'] ? {
    /^aws.*/                      => 'aws',
    'hatcher'                     => 'hatcher',
    'miserver'                    => 'miserver',
    /^(macc|kubernetes_macc_.*)$/ => 'macc',
    /^(ictc|kubernetes_ictc_.*)$/ => 'ictc',
    default                       => 'no-datacenter',
  }

  nebula::taghosts::tag { $datacenter_tag:
    order => '001',
  }

  if $facts['kernel'] == 'Linux' {
    nebula::taghosts::tag { 'linux':
      order => '002',
    }
  }

  if $facts['is_virtual'] {
    nebula::taghosts::tag { 'virtual':
      order => '003',
    }
  }

  case $facts['dmi']['manufacturer'] {
    'Dell Inc.': {
      nebula::taghosts::tag { 'dell':
        order => '003',
      }
    }

    /^HPE?$/: {
      nebula::taghosts::tag { 'hp':
        order => '003',
      }
    }

    default: {
      unless $facts['is_virtual'] {
        nebula::taghosts::tag { 'no-manufacturer':
          order => '003',
        }
      }
    }
  }

  if $facts['os']['family'] == 'Debian' {
    $os_name = $facts['os']['name'] ? {
      'Ubuntu' => 'ubuntu',
      default  => 'debian',
    }

    nebula::taghosts::tag { $os_name:
      order => '004',
    }

    nebula::taghosts::tag { $facts['os']['distro']['codename']:
      order => '005',
    }
  }
}
