
# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::www_lib::vhosts::datamart
#
# datamart virtual host
#
# @example
#   include nebula::profile::www_lib::vhosts::datamart
class nebula::profile::www_lib::vhosts::datamart (
  String $prefix,
  String $domain,
  String $ssl_cn = 'datamart.lib.umich.edu',
  String $docroot = '/www/datamart.lib/public'
) {
  $servername = "${prefix}datamart.${domain}"

  file { "${apache::params::logroot}/datamart.lib":
    ensure => 'directory'
  }

  nebula::apache::www_lib_vhost { 'datamart-http':
    servername     => $servername,
    docroot        => $docroot,
    logging_prefix => 'datamart.lib/',

    rewrites       => [
      {
        rewrite_rule => '^(.*)$ https://%{HTTP_HOST}$1 [L,R]'
      },
    ]
  }

  nebula::apache::www_lib_vhost { 'datamart-https':
    servername     => $servername,
    docroot        => $docroot,
    logging_prefix => 'datamart.lib/',

    ssl            => true,
    ssl_cn         => $ssl_cn,
    cosign         => true,

    directories    => [
      {
        provider      => 'directory',
        path          => $docroot,
        allowoverride => 'None',
        options       => '+ExecCGI -MultiViews +SymLinksIfOwnerMatch',
        require       => 'all granted',
        addhandlers   => [
          {
            extensions => ['cgi'],
            handler    => 'cgi-script'
          }
        ]
      }
    ],

    rewrites       => [
      {
        rewrite_cond => ['%{REQUEST_URI} !^/cosign',
                        '%{DOCUMENT_ROOT}%{REQUEST_FILENAME} !-f'],
        rewrite_rule => '^(.*)$ /dispatch.cgi/$1 [qsappend,last]'
      }
    ]

  }
}
