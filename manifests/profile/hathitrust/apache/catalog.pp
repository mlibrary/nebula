# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::apache::catalog
#
# catalog.hathitrust.org virtual host
#
# @example
#   include nebula::profile::hathitrust::apache::catalog
class nebula::profile::hathitrust::apache::catalog (
  String $sdrroot,
  Hash $default_access,
  Array[String] $haproxy_ips,
  String $ssl_cert,
  String $ssl_key,
  String $ssl_chain,
  String $prefix,
  String $domain,
  String $docroot = '/htapps/catalog/web',
) {

  $servername = "${prefix}catalog.${domain}"

  apache::vhost { "m.${servername} redirection":
    servername        => "m.${servername}",
    docroot           => false,
    port              => '80',
    redirect_source   => '/',
    redirect_status   => 'permanent',
    redirect_dest     => "https://m.${prefix}${domain}",
    error_log_file    => 'error.log',
    access_log_file   => 'access.log',
    access_log_format => 'combined',
  }



  apache::vhost { "${servername} ssl":
    servername        => $servername,
    port              => 443,
    serveraliases     => ["m.${prefix}${domain}"],
    manage_docroot    => false,
    docroot           => $docroot,
    error_log_file    => 'catalog/error.log',
    access_log_file   => 'catalog/access.log',
    access_log_format => 'combined',
    directoryindex    => 'index.html index.htm index.php index.phtml index.shtml',
    ssl               => true,
    ssl_cert          => $ssl_cert,
    ssl_key           => $ssl_key,
    ssl_chain         => $ssl_chain,

    directories       => [
      {
        provider => 'filesmatch',
        location =>  '~$',
        require  => 'all denied'
      },
      {
        provider       => 'directory',
        path           => $docroot,
        options        => ['FollowSymlinks'],
        allow_override => ['all'],
        require        => $default_access,
      },
      {
        provider => 'directory',
        path     =>  "${sdrroot}/common/web",
        require  => $default_access,
      },
    ],

    aliases           => [
      {
        aliasmatch => '^/favicon.ico$',
        path       => "${sdrroot}/common/web/favicon.ico"
      },
      {
        alias => '/common/',
        path  => "${sdrroot}/common/web/"
      }
    ],

    rewrites          => [
      {

        # redirect top-level page to www.hathitrust.org, but not for mobile or orphanworks host names
        #
        # 2010-11-12 csnavely per jjyork
        #
        # adapted to take effect for catalog.hathitrust.org only after consolidating m.hathitrust.org and
        # orphanworks.hathtrust.org into this virtual host
        #
        # 2012-04-17 skorner per dueberb

        rewrite_cond => "%{HTTP_HOST}    ^(${prefix}catalog)  [nocase]",
        rewrite_rule => "^(/$|/index.html$)  https://${prefix}www.${domain}/  [redirect=permanent,last]"

      }
    ]
  }
}
