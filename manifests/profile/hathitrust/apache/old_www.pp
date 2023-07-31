# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::apache::www
#
# old.www.hathitrust.org virtual host
#
# @example
#   include nebula::profile::hathitrust::apache::old_www
class nebula::profile::hathitrust::apache::old_www (
  String $sdrroot,
  Hash $default_access,
  Array[String] $haproxy_ips,
  Hash $ssl_params,
  String $prefix,
  String $domain,
  String $docroot = '/htapps/old.www'
) {

  $servername = "old.${prefix}www.${domain}"

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
    directoryindex     => 'index.html index.htm index.phtml index.shtml',
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
        allow_override => ['None'],
        require        => $default_access,
      },
    ],

    aliases            => [
      {
        aliasmatch => '^/favicon.ico$',
        path       => "${sdrroot}/common/web/favicon.ico"
      },
    ],

    headers            => 'set "Strict-Transport-Security" "max-age=31536000"',

  }
}
