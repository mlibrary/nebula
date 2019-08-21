
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
  String $vhost_root,
  String $ssl_cn = 'datamart.lib.umich.edu',
  String $docroot = '/www/datamart.lib/public'
) {
  $servername = "${prefix}datamart.${domain}"

  nebula::apache::www_lib_vhost { 'datamart-http':
    servername     => $servername,
    docroot        => $docroot,
    error_log_file => 'datamart.lib/error.log',
    # TODO: access.log??
    # TODO: prefix for log directory, make log dir?

    rewrites       =>  [
      {
        rewrite_rule => '^(.*)$ https://%{HTTP_HOST}$1 [L,R]'
      },
    ]
  }

  nebula::apache::www_lib_vhost { 'datamart-https':
    servername  => $servername,
    docroot     => $docroot,
    ssl         => true,
    ssl_cn      => $ssl_cn,
    cosign      => true,

    directories => [
      {
        provider      => 'directory',
        path          => '/www/datamart.lib/public',
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

    access_logs =>  [
      {
        file   => 'datamart.lib/access.log',
        format => 'combined'
      }
    ],

    rewrites    => [
      {
        rewrite_cond => ['%{REQUEST_URI} !^/cosign',
                        '%{DOCUMENT_ROOT}%{REQUEST_FILENAME} !-f'],
        rewrite_rule => '^(.*)$ /dispatch.cgi/$1 [qsappend,last]'
      }
    ]

  }
}
