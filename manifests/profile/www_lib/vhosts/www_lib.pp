
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
  String $www_lib_root = '/www/www.lib-fallback',
  String $docroot = "${www_lib_root}/web"
) {

  nebula::apache::www_lib_vhost { 'www.lib-ssl':
    servername                    => "${prefix}www.${domain}",
    ssl                           => true,
    usertrack                     => true,
    cosign                        => true,
    docroot                       => $docroot,
    directories                   => [
      {
        provider       => 'directory',
        path           => "${www_lib_root}/cgi",
        allow_override => ['None'],
        options        => ['None'],
        require        => $nebula::profile::www_lib::apache::default_access,
      },
      {
        provider       => 'directory',
        path           => $docroot,
        options        => ['IncludesNOEXEC','Indexes','FollowSymLinks','MultiViews'],
        allow_override => ['AuthConfig','FileInfo','Limit','Options'],
        require        => $nebula::profile::www_lib::apache::default_access
      },
    ],
  }
}
