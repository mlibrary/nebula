# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::www_lib::vhosts::publishing
#
# Readership map hosting
#
# Wordpress virtual hosts for Publishing
#
# @example
#   include nebula::profile::www_lib::vhosts::publishing
class nebula::profile::www_lib::vhosts::publishing (
  String $docroot = '/www/maps.publishing/web',
) {
  apache::vhost { 'maps.publishing-http':
    servername     => 'maps.publishing.umich.edu',
    ssl            => false,
    port           => 80,
    docroot        => $docroot,
    manage_docroot => false,
    rewrites       => [
      {
        rewrite_rule => '^(.*)$ https://%{HTTP_HOST}$1 [L,NE,R]'
      },
    ],
  }

  # Note that this vhost listens on 443 but is HTTP, because HAProxy terminates
  # SSL. We pass an ENV var to signal that the request is over HTTPS for app
  # URL generation, etc.
  apache::vhost { 'maps.publishing-https':
    servername     => 'https://maps.publishing.umich.edu',
    docroot        => $docroot,
    manage_docroot => false,
    ssl            => true,
    ssl_cert       => '/etc/ssl/certs/maps.publishing.umich.edu.crt',
    ssl_key        => '/etc/ssl/private/maps.publishing.umich.edu.key',
    port           => 443,
    setenv         => ['HTTPS on'],
    setenvifnocase => '^Authorization$ "(.+)" HTTP_AUTHORIZATION=$1',
    directories    => [
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
