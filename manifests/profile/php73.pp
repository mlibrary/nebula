
# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
#
# nebula::profile::php73
#
# Installs php73 from community repositories.
class nebula::profile::php73 (
) {

  apt::source { 'php73':
    location     => 'https://packages.sury.org/php/',
    key          =>  {
      id     => '15058500A0235D97F5D10063B188E2B695BD4743',
      source => 'https://packages.sury.org/php/apt.gpg'
    },
    release      => $::lsbdistcodename,
    repos        => 'main',
    architecture => $::os['architecture'],
  }

  package { ['php-common',
  'php-geoip',
  'php-igbinary',
  'php-imagick',
  'php-memcached',
  'php-msgpack',
  'php-pear',
  'php-redis',
  'php-xdebug',
  'php-xml',
  'php7.3-cli',
  'php7.3-common',
  'php7.3-curl',
  'php7.3-fpm',
  'php7.3-gd',
  'php7.3-json',
  'php7.3-ldap',
  'php7.3-mysql',
  'php7.3-opcache',
  'php7.3-readline',
  'php7.3-sqlite3',
  'php7.3-xml' ]: }


}
