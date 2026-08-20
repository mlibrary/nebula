# Copyright (c) 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::www_lib::apache::fulcrum
#
# Apache config and surrounding setup required to be a fulcrum.org web server.
# Note that this is different than a web server fully able to run an instance
# of Fulcrum. This profile includes all of the official domains and redirects
# for Fulcrum-the-service.
class nebula::profile::www_lib::apache::fulcrum (
) {
  @nebula::apache::ssl_keypair { 'fulcrum.org': }

  include nebula::profile::www_lib::vhosts::fulcrum

  class { 'apache::mod::shib': }

  file { '/etc/apache2/mods-available/shib2.conf':
    ensure  => 'file',
    content => template('nebula/profile/www_lib/shib2.conf.erb'),
    require => File['/etc/apache2/mods-available'],
  }

  file { '/etc/apache2/mods-enabled/shib2.conf':
    ensure  => 'link',
    target  => '/etc/apache2/mods-available/shib2.conf',
    require => File['/etc/apache2/mods-available/shib2.conf'],
  }
}
