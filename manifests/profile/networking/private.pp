# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::networking::private
#
# Configure private network interface. The private address is constructed by
# replacing the last octet of address_template with the last octet of the
# public IP address.
#
# @example
#   include nebula::profile::networking::private
class nebula::profile::networking::private (
  String $address_template = '192.168.0.%s',
  String $netmask = '255.255.255.0',
  String $network = '192.168.0.0',
  String $broadcast = '192.168.255.255',
  Optional[String] $interface = undef,
) {

  if !$interface and $facts['os']['family'] == 'Debian' and $::lsbdistcodename != 'jessie' and $facts['is_virtual']
    and 'ens4' in $facts['networking']['interfaces'] {
    $real_interface = 'ens4'
  } else {
    $real_interface = $interface
  }

  if $real_interface {
    $address = sprintf($address_template,split($facts['networking']['ip'],'\.')[-1])

    file { '/etc/network/interfaces.d/private':
      content      => template('nebula/profile/networking/private.erb'),
      validate_cmd => "/sbin/ifdown ${real_interface}"
    }

    exec { "ifup ${real_interface}":
      command => "/sbin/ifup ${real_interface}",
      onlyif  => "/usr/bin/test $(cat /sys/class/net/${real_interface}/operstate) = 'down'"
    }

    Exec["ifup ${real_interface}"] -> Service <| tag == 'private_network' |>
    Exec["ifup ${real_interface}"] -> Mount <| tag == 'private_network' |>

  } else {
    err('No network interface to configure')
  }
}

