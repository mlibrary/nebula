
# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::www_lib::vhosts::www_lib
#
# www.lib.umich.edu virtual host
#
# @example
#   include nebula::profile::www_lib::vhosts::www_lib
class nebula::profile::www_lib::vhosts::www_lib (
  String $prefix,
  String $domain,
  String $vhost_root,
  String $ssl_cn = 'www.lib.umich.edu'
) {
  $skynet_fragment = @(EOT)
    CookieTracking on
    CookieDomain .lib.umich.edu
    CookieName skynet
  |EOT

  nebula::apache::www_lib_vhost { 'www.lib-ssl':
    servername                    => "${prefix}www.${domain}",
    ssl                           => true,
    error_log_file                => 'error.log',
    vhost_root                    => $vhost_root,
    cosign                        => true,
    cosign_public_access_off_dirs => [
      {
        provider => 'location',
        path     => '/login'
      },
      {
        provider => 'location',
        path     => '/vf/vflogin_dbsess.php'
      },
      {
        provider => 'location',
        path     => '/pk',
      },
      {
        provider => 'directory',
        path     => "${vhost_root}/cgi/l/login",
      },
      {
        provider => 'directory',
        path     => "${vhost_root}/cgi/m/medsearch"
      }
    ],

    access_logs                   => [
      {
        file   => 'access.log',
        format => 'combined'
      },
      {
        file   => 'clickstream.log',
        format => 'usertrack'
      },
    ],

    custom_fragment               => $skynet_fragment,

    # TODO: hopefully these can all be removed
    rewrites                      => [
      {
        # rewrite for wsfh
        #
        # remote after 2008-12-31
        #
        # jhovater - 2008-12-04 varnum said to keep
        # 2008-08-28 csnavely per varnum
        rewrite_rule =>  '^/wsfh		http://www.wsfh.org/	[redirect,last]'
      },
      {
        # rewrites for aol-like, tinyurl-like "go" function
        #
        # 2007-05 csnavely
        # 2013-01-23 keep for drupal7 - aelkiss per bertrama
        rewrite_rule => '^/go/pubmed  http://searchtools.lib.umich.edu/V?func=native-link&resource=UMI01157 [redirect,last]'
      },
      {
        # Redirect Islamic Manuscripts to the Lib Guides.
        #
        # Check with nancymou and ekropf for potential removal after 2016-09-01
        #
        # 2016-08-29 skorner per nancymou
        rewrite_rule => '^/islamic	http://guides.lib.umich.edu/islamicmss/find 	[redirect=permanent,last]'
      },
    ];
  }
}
