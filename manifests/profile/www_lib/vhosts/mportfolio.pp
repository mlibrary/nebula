
# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::www_lib::vhosts::mportfolio
#
# mportfolio virtual host
#
# @example
#   include nebula::profile::www_lib::vhosts::mportfolio
class nebula::profile::www_lib::vhosts::mportfolio (
  String $prefix,
  String $domain,
  String $ssl_cn = 'www.mportfolio.umich.edu',
  String $docroot = '/www/www.mportfolio/web'
) {
  $servername = "${prefix}www.mportfolio.${domain}"

  file { "${apache::params::logroot}/mportfolio":
    ensure => 'directory',
  }

  nebula::apache::www_lib_vhost { 'mportfolio-http':
    servername     => $servername,
    docroot        => $docroot,
    logging_prefix => 'mportfolio/',

    rewrites       => [
      {
        rewrite_rule => '^(.*)$ https://%{HTTP_HOST}$1 [L,R]'
      },
    ],
  }

  nebula::apache::www_lib_vhost { 'mportfolio-https':
    servername     => $servername,
    docroot        => $docroot,
    logging_prefix => 'mportfolio/',

    ssl            => true,
    ssl_cn         => $ssl_cn,
    cosign         => true,

    directories    => [
      {
        provider       => 'directory',
        path           => $docroot,
        options        => 'IncludesNOEXEC Indexes FollowSymLinks MultiViews',
        allow_override => 'AuthConfig FileInfo Limit Options',
        require        => $nebula::profile::www_lib::apache::default_access,
      },
    ],

  }
}
