# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::www_lib::php
#
# Install php dependencies for www_lib applications
#
# @example
#   include nebula::profile::www_lib::php
class nebula::profile::www_lib::php () {
  include nebula::profile::php73

  package {
    [
      'php5.6-cli',
      'php5.6-common',
      'php5.6-curl',
      'php5.6-fpm',
      'php5.6-gd',
      'php5.6-json',
      'php5.6-ldap',
      'php5.6-mbstring',
      'php5.6-mysql',
      'php5.6-opcache',
      'php5.6-readline',
      'php5.6-sqlite3',
      'php5.6-xml',
    ]:
  }

  package {
    [
      'php-mdb2',
      'php-mdb2-driver-mysql'
    ]:
  }

  class { '::php':
    ensure       => present,     # Don't touch stuff from above; should be equivalent
    manage_repos => false, # Set true to add dotdeb repos
    fpm          => true,
    composer     => false,     # System-wide composer seems iffy unless using dotdeb
    pear         => true,          # We're using this for PEAR, so set to true
    phpunit      => true,       # Unsure whether this should be system or app-level

    # Some of these may only be needed for mirlyn, so if/when the mirlyn API is
    # removed, we should be able to remove these

    extensions   => {
      'Archive_Tar'           => { package_prefix => '', provider => 'pear' },
      # Console_Getopt
      'Console_Table'         => { package_prefix => '', provider => 'pear' },
      'DB'                    => { package_prefix => '', provider => 'pear' },
      'DB_DataObject'         => { package_prefix => '', provider => 'pear' },
      'Date'                  => { package_prefix => '', provider => 'pear' },
      'File_MARC'             => { package_prefix => '', provider => 'pear' },
      'HTTP_Request'          => { package_prefix => '', provider => 'pear' },
      'HTTP_Request2'         => { package_prefix => '', provider => 'pear' },
      'HTTP_Session2'         => { ensure => 'beta', package_prefix => '', provider => 'pear' },
      'Log'                   => { package_prefix => '', provider => 'pear' },
      # MDB2
      # MDB2_Driver_mysql
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
      # XML_Util
    },
  }

  class { 'php::apache_config':
    ini_file => '/etc/php/5.6/apache2/php.ini',
    settings => {
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
