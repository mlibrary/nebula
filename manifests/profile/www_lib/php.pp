# Copyright (c) 2019-2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::www_lib::php
#
# Install php dependencies for www_lib applications
#
# @example
#   include nebula::profile::www_lib::php
class nebula::profile::www_lib::php (
  String $default_php_version = '8.1'
) {

  # Set the php repo
  apt::source { 'php-community':
    location     => 'https://packages.sury.org/php/',
    key          =>  {
      name   => 'php-community-sury.org.gpg',
      source => 'https://packages.sury.org/php/apt.gpg'
    },
    release      => $::lsbdistcodename,
    repos        => 'main',
    architecture => $::os['architecture'],
  }

  # Set default php
  class { '::php::globals':
    php_version => $default_php_version,
    config_root => "/etc/php/${default_php_version}",
  }

  # Install default php packages. Some are implicit as described 
  # below while rest have to be specified.
  #
  # php*-cli, php*-common, php*-fpm and php-pear get installed by 
  # the puppet PHP module by default (if enabled). Devel packages 
  # are implicit also but we aren't using them.
  #
  # Note: The PHP module doesn't use ensure_packages so if we don't
  # remove them below we will get duplicate warnings despite our
  # use of ensure_packages.
  #
  ensure_packages (
    [
      "php${default_php_version}-igbinary",
      "php${default_php_version}-imagick",
      "php${default_php_version}-memcached",
      "php${default_php_version}-msgpack",
      "php${default_php_version}-redis",
      "php${default_php_version}-xdebug",
      "php${default_php_version}-curl",
      "php${default_php_version}-gd",
      "php${default_php_version}-ldap",
      "php${default_php_version}-mbstring",
      "php${default_php_version}-mysql",
      "php${default_php_version}-oauth",
      "php${default_php_version}-opcache",
      "php${default_php_version}-readline",
      "php${default_php_version}-sqlite3",
      "php${default_php_version}-xml",
    ]
  )

  # Install php 5.6
  ensure_packages (
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
    ]
  )

  # Pear and database packages
  ensure_packages (
    [
      'php-mdb2',
      'php-mdb2-driver-mysql'
    ]
  )

  # Configure FPM config file
  php::config { 'fpm php.ini':
    file   => "/etc/php/${default_php_version}/fpm/php.ini",
    config => {
      'PHP/short_open_tag'          => 'On',
      'PHP/max_input_vars'          => '2000',
      'PHP/memory_limit'            => '256M',
      'PHP/error_reporting'         => 'E_ALL & ~E_DEPRECATED',
      'PHP/upload_max_filesize'     => '128M',
      'PHP/post_max_size'           => '128M',
      'Date/date.timezone'          => 'America/Detroit',
      'mail function/sendmail_path' => '/usr/sbin/sendmail -t -i',
    }
  }

  # Configure default PHP
  class { '::php':
    ensure       => present, # Don't touch stuff from above; should be equivalent
    manage_repos => false, # Set true to add dotdeb repos
    fpm          => true,
    fpm_user     => 'nobody',
    fpm_group    => 'nogroup',
    composer     => false, # System-wide composer seems iffy unless using dotdeb
    pear         => true,  # We're using this for PEAR, so set to true
    phpunit      => true,  # Unsure whether this should be system or app-level

    # Configure FPM default pool ('www')
    # 
    # The 'www' pool is hard-coded in the php module so can't be created here.
    #
    # The php::fpm::pool class is intended to be used to create other pools only.
    #
    # Options to circumvent the php module design is to either:
    #   1. Adjust the ::php { fpm_pools => {settings} } here.
    #   2. Adjust the settings in hiera as:
    #     - php::params::fpm_tools:
    #         www:
    #   3. Set fpm_pools => {} to disable default 'www' creation and then 
    #      create it manually using php::fpm::pool class like any pool. This 
    #      is the option we are choosing.
    #
    #
    fpm_pools    => {
      'www' => {
        'user'                      => 'nobody',
        'group'                     => 'nogroup',
        'listen'                    => "/run/php/php${default_php_version}-fpm.sock",
        'listen_owner'              => 'nobody',
        'listen_group'              => 'nogroup',
        'pm'                        => 'dynamic',
        'pm_max_children'           => 10,
        'pm_start_servers'          => 2,
        'pm_min_spare_servers'      => 1,
        'pm_max_spare_servers'      => 3,

        # Default PHP puppet module settings from fpm_pools
        'catch_workers_output'      => 'no',
        'pm_max_requests'           => 0,
        'request_terminate_timeout' => 0,
      }
    },

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

  # PHP 5.6 defaults to using www-data, while we need to use nobody:nogroup for sockets
  file_line {
    default:
      path    => '/etc/php/5.6/fpm/pool.d/www.conf',
      require => Package['php5.6-fpm'],
      ;
    'PHP 5.6 FPM user':
      line  => 'user = nobody',
      match => '^user =',
      ;
    'PHP 5.6 FPM group':
      line  => 'group = nogroup',
      match => '^group =',
      ;
    'PHP 5.6 FPM listen.owner':
      line  => 'listen.owner = nobody',
      match => '^listen\.owner =',
      ;
    'PHP 5.6 FPM listen.group':
      line  => 'listen.group = nogroup',
      match => '^listen\.group =',
      ;
  }

  # Configure Apache PHP module
  class { 'php::apache_config':
    inifile  => '/etc/php/5.6/apache2/php.ini',
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
