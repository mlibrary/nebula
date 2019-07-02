
# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::geoip
#
# Install and configure geoip geolocation service
#
# @param license_key the GeoIP license key
# @param user_id The GeoIP user id
# @param product_id The MaxMind GeoIP product id, by default 106 for GeoIP Country
#
# @example
#   class { 'nebula::profile::geoip':
#     license_key    => 'mykey',
#     user_id        => '12345
#   }
class nebula::profile::geoip (
  String $license_key = 'CHANGEME',
  String $user_id = 'CHANGEME',
  # MaxMind GeoIP Country
  String $product_id = '106'
) {
  package { ['geoip-bin', 'geoipupdate']: }

  cron { 'update GeoIP database':
    command => '/usr/bin/geoipupdate -f /etc/GeoIP.conf -d /usr/share/GeoIP',
    user    => 'root',
    minute  => '37',
    hour    => '7',
    weekday => '1'
  }

  file { '/etc/GeoIP.conf':
    ensure  => 'present',
    mode    => '0640',
    owner   => 'root',
    group   => 'root',
    content => inline_template(@("GEOIP_CONF"))
      LicenseKey ${license_key}
      UserId ${user_id}
      ProductIds ${product_id}
      | GEOIP_CONF
  }

}
