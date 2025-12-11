# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
#
# nebula::profile::php73
#
# Installs php73 from community repositories.
class nebula::profile::php73 (
) {
  apt::source { 'php-community':
    source_format => 'sources',
    location      => ['https://packages.sury.org/php/'],
    release       => $facts['os']['distro']['codename'],
    repos         => ['main'],
    architecture  => $facts['os']['architecture'],
    keyring       => '/etc/apt/keyrings/php-community-sury.org.gpg',
  }

  apt::keyring { 'php-community-sury.org.gpg':
    source => 'puppet:///modules/nebula/apt/keyrings/php-community-sury.org.gpg',
  }

  ensure_packages (
    [
      'php7.3-igbinary',
      'php7.3-imagick',
      'php7.3-memcached',
      'php7.3-msgpack',
      #  'php-pear',
      'php7.3-redis',
      'php7.3-xdebug',
      'php7.3-bcmath',
      'php7.3-cli',
      'php7.3-common',
      'php7.3-curl',
      'php7.3-fpm',
      'php7.3-gd',
      'php7.3-json',
      'php7.3-ldap',
      'php7.3-mbstring',
      'php7.3-mysql',
      'php7.3-opcache',
      'php7.3-readline',
      'php7.3-sqlite3',
      'php7.3-xml',
    ]
  )

  php::config { 'fpm php.ini':
    file   => '/etc/php/7.3/fpm/php.ini',
    config => {
      'PHP/short_open_tag'          => 'On',
      'PHP/max_input_vars'          => '2000',
      'PHP/memory_limit'            => '256M',
      'PHP/error_reporting'         => 'E_ALL & ~E_DEPRECATED',
      'PHP/post_max_size'           => '128M',
      'PHP/upload_max_filesize'     => '128M',
      'Date/date.timezone'          => 'America/Detroit',
      'mail function/sendmail_path' => '/usr/sbin/sendmail -t -i',
    }
  }
}
