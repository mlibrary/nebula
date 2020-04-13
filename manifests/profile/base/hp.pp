# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::base::hp
#
# Customizations specific to physical HP/HPE machines
#
# @example
#   include nebula::profile::base::hp
class nebula::profile::base::hp {
  kmod::blacklist { 'hpwdt':
    file =>  '/etc/modprobe.d/hpwdt-blacklist.conf',
  }

  kmod::blacklist { 'acpi_power_meter':
    file =>  '/etc/modprobe.d/acpi_power_meter-blacklist.conf',
  }

  package { 'ssacli': }

  $http_files = lookup('nebula::http_files')
# hp raid status monitoring script
  file { '/usr/local/sbin/hp_raid_status.sh':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0750',
    source => "https://${http_files}/ae-utils/bins/hp_raid_status.sh",
  }

# Create cron to check raid status daily at 6AM
  cron { 'check hp raid status':
    command => '/usr/local/sbin/hp_raid_status.sh',
    user    => 'root',
    minute  => '0',
    hour    => '6',
  }

}
