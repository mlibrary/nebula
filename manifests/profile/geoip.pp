
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
    command => '/l/local/bin/geoipupdate -f /etc/GeoIP.conf -d /usr/share/GeoIP',
    user    => 'root',
    minute  => '37',
    hour    => '7',
    weekday => '1'
  }

}
