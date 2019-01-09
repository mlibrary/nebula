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
  include nebula::profile::geoip

  package {
    [
      'php7.0-curl',
      'php7.0-gd',
      'php-geoip', # PECL
      'php-http', # PECL
      'php7.0-ldap',
      'php7.0-mysql',
      'php-mdb2',
      'php-mdb2-driver-mysql',
      'php-smarty',
      'php7.0-xsl',
      'libapache2-mod-php7.0',
      'pear-channels'
    ]:
  }

  -> class { '::php':
    ensure       => present,     # Don't touch stuff from above; should be equivalent
    manage_repos => false, # Set true to add dotdeb repos
    fpm          => false,          # We only use mod_php at present
    composer     => false,     # System-wide composer seems iffy unless using dotdeb
    pear         => true,          # We're using this for PEAR, so set to true
    phpunit      => true,       # Unsure whether this should be system or app-level

    extensions   => {
      'Archive_Tar'           => { package_prefix => '', provider => 'pear' },
      'DB'                    => { package_prefix => '', provider => 'pear' },
      'DB_DataObject'         => { package_prefix => '', provider => 'pear' },
      'Date'                  => { package_prefix => '', provider => 'pear' },
      'File_MARC'             => { package_prefix => '', provider => 'pear' },
      'HTTP_Request'          => { package_prefix => '', provider => 'pear' },
      'HTTP_Request2'         => { package_prefix => '', provider => 'pear' },
      'HTTP_Session2'         => { ensure => 'beta', package_prefix => '', provider => 'pear' },
      'Log'                   => { package_prefix => '', provider => 'pear' },
      'Mail'                  => { package_prefix => '', provider => 'pear' },
      'Net_SMTP'              => { package_prefix => '', provider => 'pear' },
      'Net_Socket'            => { package_prefix => '', provider => 'pear' },
      'Net_URL'               => { package_prefix => '', provider => 'pear' },
      'Net_URL2'              => { package_prefix => '', provider => 'pear' },
      'Pager'                 => { package_prefix => '', provider => 'pear' },
      'PhpDocumentor'         => { package_prefix => '', provider => 'pear' },
      'Structures_DataGrid'   => { ensure => 'beta', package_prefix => '', provider => 'pear' },
      'Structures_LinkedList' => { ensure => 'beta', package_prefix => '', provider => 'pear' },
      'XML_Parser'            => { package_prefix => '', provider => 'pear' },
      'XML_Serializer'        => { ensure => 'beta', package_prefix => '', provider => 'pear' },
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
