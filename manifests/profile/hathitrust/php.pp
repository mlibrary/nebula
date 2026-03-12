# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::php
#
# Install php dependencies for HathiTrust applications
#
# @example
#   include nebula::profile::hathitrust::php
class nebula::profile::hathitrust::php () {
  include nebula::profile::hathitrust::apache

  package {
    [
      'php-geoip',
      'php-mdb2',
      'php-mdb2-driver-mysql',
      'pear-channels'
    ]:
      ensure => 'absent'
  }

  package {
    [
      'php-curl',
      'php-gd',
      'php-http', # PECL
      'php-ldap',
      'php-mbstring',
      'php-mysql',
      # n.b. php-pear is automatically installed via class php below
      'php-raphf',
      'php-xml',
      'php-yaml',
      'libapache2-mod-php',
      'smarty3',
    ]:
  }

  -> class { 'php':
    ensure       => present,     # Don't touch stuff from above; should be equivalent
    manage_repos => false, # Set true to add dotdeb repos
    fpm          => false,          # We only use mod_php at present
    composer     => false,     # System-wide composer seems iffy unless using dotdeb
    pear         => true,          # We're using this for PEAR, so set to true
    phpunit      => true,       # Unsure whether this should be system or app-level

    extensions   => {
      'File_MARC'     => { package_prefix => '', provider => 'pear' },
      'HTTP_Request2' => { package_prefix => '', provider => 'pear' },
      'Pager'         => { package_prefix => '', provider => 'pear' },
    },
  }

  -> class { 'php::apache_config':

    settings     => {
      'PHP/short_open_tag'          => 'On',
      'PHP/max_input_vars'          => '2000',
      'PHP/memory_limit'            => '256M',
      'PHP/error_reporting'         => 'E_ALL & ~E_DEPRECATED',
      'PHP/upload_max_filesize'     => '32M',
      'Date/date.timezone'          => 'America/Detroit',
      'mail function/sendmail_path' => '/usr/sbin/sendmail -t -i'
    },
  }
}
