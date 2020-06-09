
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
  String $ssl_cn = 'www.lib.umich.edu',
  String $www_lib_root = '/www/www.lib',
  String $docroot = "${www_lib_root}/web"
) {

  nebula::apache::www_lib_vhost { 'www.lib-ssl':
    servername                    => "${prefix}www.${domain}",
    ssl                           => true,
    usertrack                     => true,
    cosign                        => true,
    docroot                       => $docroot,
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
        path     => "${www_lib_root}/cgi/l/login",
      },
    ],

    directories                   => [
      {
        provider       => 'directory',
        path           => $docroot,
        options        => ['IncludesNOEXEC','Indexes','FollowSymLinks','MultiViews'],
        allow_override => ['AuthConfig','FileInfo','Limit','Options'],
        require        => $nebula::profile::www_lib::apache::default_access
      },
      {
        provider       => 'directory',
        path           => "${www_lib_root}/cgi",
        allow_override => ['None'],
        options        => ['None'],
        require        => $nebula::profile::www_lib::apache::default_access
      }
    ],

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
