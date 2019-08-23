
# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::www_lib::vhosts::default
#
# Default (redirection) vhosts for www.lib.umich.edu environment
#
# @example
#   include nebula::profile::www_lib::vhosts::default

class nebula::profile::www_lib::vhosts::default (
  String $prefix,
  String $domain,
  String $ssl_cn = 'www.lib.umich.edu'
) {

  nebula::apache::www_lib_vhost { '000-default':
    ssl        => false,
    ssl_cn     => $ssl_cn,
    servername => "${prefix}${domain}",
    docroot    => false,
    rewrites   => [
      {
        # redirect all access to https except monitoring
        rewrite_cond => '%{REQUEST_URI} !^/monitor/monitor.pl',
        rewrite_rule => '^(.*)$ https://%{HTTP_HOST}$1 [L,NE,R]'
      }
    ];
  }

  nebula::apache::www_lib_vhost { '000-default-ssl':
    ssl         => true,
    ssl_cn      => $ssl_cn,
    servername  => $::fqdn,
    directories => [ $nebula::profile::apache::monitoring::location ],
    aliases     => [ $nebula::profile::apache::monitoring::scriptalias ],
    docroot     => false,
    rewrites    => [
      {
        rewrite_cond => '%{REQUEST_URI} !^/monitor/monitor.pl',
        rewrite_rule => '^(.*)$ https://%{HTTP_HOST}$1 [L,NE,R]'
      }
    ];
  }
}
