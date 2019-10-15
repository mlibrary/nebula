
# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::www_lib::vhosts::openmich
#
# Open Michigan virtual host
#
# @example
#   include nebula::profile::www_lib::vhosts::openmich
class nebula::profile::www_lib::vhosts::openmich (
  String $prefix,
  String $domain,
  String $ssl_cn = 'open.umich.edu',
  String $docroot = '/www/openmich/web'
) {
  $servername = "${prefix}open.umich.edu"

  file { "${apache::params::logroot}/openmich":
    ensure => 'directory'
  }

  nebula::apache::www_lib_vhost { 'openmich-http':
    servername     => $servername,
    serveraliases  => ["${prefix}openmich.www.${domain}"],
    docroot        => $docroot,
    logging_prefix => 'openmich/',

    rewrites       => [
      {
        rewrite_rule => '^(.*)$ https://%{HTTP_HOST}$1 [L,R]'
      },
    ]
  }

  nebula::apache::www_lib_vhost { 'openmich-https':
    servername     => $servername,
    serveraliases  => ["${prefix}openmich.www.${domain}"],
    docroot        => $docroot,
    logging_prefix => 'openmich/',

    ssl            => true,
    ssl_cn         => $ssl_cn,
    cosign         => false,

    directories    => [
      {
        provider       => 'directory',
        path           => $docroot,
        options        => 'IncludesNOEXEC Indexes FollowSymLinks MultiViews',
        allow_override => 'AuthConfig FileInfo Limit Options',
        require        => $nebula::profile::www_lib::apache::default_access
      }
    ],
  }
}
