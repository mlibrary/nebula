# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::apache::www
#
# www.hathitrust.org virtual host
#
# @example
#   include nebula::profile::hathitrust::apache::www
class nebula::profile::hathitrust::apache::www (
  String $sdrroot,
  Hash $default_access,
  Array[String] $haproxy_ips,
  Hash $ssl_params,
  String $prefix,
  String $domain,
  String $docroot = '/htapps/www'
) {

  cron { 'purge non-babel apache access logs':
    command => '/usr/bin/find /var/log/apache2/www -type f -name "access_log*" -mtime +7 -exec /bin/rm {} \; > /dev/null 2>&1',
    user    => 'root',
    minute  => '27',
    hour    => '1',
  }

  cron { 'compress non-babel apache access logs':
    command => '/usr/bin/find /var/log/apache2/www -type f -name "access_log*" ! -name "*.gz" -mtime +0 -exec /usr/bin/pigz -9 {} \; > /dev/null 2>&1',
    user    => 'root',
    minute  => '28',
    hour    => '1',
  }

  $servername = "${prefix}www.${domain}"

  apache::vhost { "${servername} ssl":
    servername         => $servername,
    use_canonical_name => 'On',
    port               => '443',
    manage_docroot     => false,
    docroot            => $docroot,
    error_log_file     => 'www/error.log',
    access_log_file    => 'www/access.log',
    access_log_format  => 'combined',
    setenv             => ["SDRROOT ${docroot}"],
    directoryindex     => 'index.html index.htm index.php index.phtml index.shtml',
    *                  => $ssl_params,

    directories        => [
      {
        provider => 'filesmatch',
        location =>  '~$',
        require  => 'all denied'
      },
      {
        provider       => 'directory',
        path           => $docroot,
        options        => ['IncludesNoExec','Indexes','FollowSymLinks','MultiViews'],
        allow_override => ['AuthConfig','FileInfo','Limit','Options'],
        require        => $default_access,
      },
      {
        provider => 'directory',
        path     =>  "${sdrroot}/firebird-common",
        require  => $default_access,
      },
      {
        provider => 'directory',
        path     =>  "${sdrroot}/common/web",
        require  => $default_access,
      },
    ],

    aliases            => [
      {
        aliasmatch => '^/favicon.ico$',
        path       => "${sdrroot}/firebird-common/dist/favicon.ico"
      },
      {
        alias => '/common/firebird/',
        path  => "${sdrroot}/firebird-common/"
      },
      {
        alias => '/common/',
        path  => "${sdrroot}/common/web/"
      }
    ],

    headers            => 'set "Strict-Transport-Security" "max-age=31536000"',

  }
}
