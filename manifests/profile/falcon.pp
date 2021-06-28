# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::falcon (
  String $cid,
) {
  ensure_packages(['falcon-sensor'])
  service { 'falcon-sensor':
    ensure => 'running',
  }

  exec { 'set falcon-sensor CID':
    command => "/opt/CrowdStrike/falconctl -s '--cid=${cid}'",
    unless  => '/opt/CrowdStrike/falconctl -g --cid',
    require => Package['falcon-sensor'],
    notify  => Service['falcon-sensor'],
  }
}
