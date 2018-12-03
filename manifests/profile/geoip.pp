
# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::geoip
#
# Install and configure geoip geolocation service
#
# @example
#   include nebula::profile::geoip
class nebula::profile::geoip () {
  package { 'geoip-bin': }

  cron { 'update GeoIP database':
    command => '/usr/local/bin/geoipupdate -f /etc/GeoIP.conf -d /usr/share/GeoIP',
    user    => 'root',
    minute  => '37',
    hour    => '7',
    weekday => '1'
  }

  $http_files = lookup('nebula::http_files')
  file { '/usr/local/bin/geoipupdate':
    ensure => 'present',
    mode   => '0755',
    source => "https://${http_files}/ae-utils/bins/geoipupdate"
  }

}
