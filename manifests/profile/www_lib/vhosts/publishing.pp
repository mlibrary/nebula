# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::www_lib::vhosts::publishing
#
# Wordpress virtual hosts for Publishing
#
# @example
#   include nebula::profile::www_lib::vhosts::publishing
class nebula::profile::www_lib::vhosts::publishing (
  String $docroot = '/www/www.publishing/web',
) {
  apache::vhost { 'www.publishing-http':
    servername     => 'www.publishing.umich.edu',
    serveraliases  => ['services.publishing.umich.edu','maps.publishing.umich.edu'],
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
  apache::vhost { 'www.publishing-https':
    servername     => 'https://www.publishing.umich.edu',
    serveraliases  => ['services.publishing.umich.edu','maps.publishing.umich.edu'],
    docroot        => $docroot,
    manage_docroot => false,
    ssl            => false,
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
      {
        provider    => 'directory',
        path        => "${docroot}/campus_map",
        addhandlers => [{
          extensions => ['.php'],
          # TODO: Extract version or socket path to params/hiera
          handler    => 'proxy:unix:/run/php/php7.3-fpm.sock|fcgi://localhost'
        }],
      }
    ],
  }

  # A range of other sites served under the same Wordpress installation
  apache::vhost { 'publishing-partners-http':
    servername     => 'blog.press.umich.edu',
    serveraliases  => [
      'www.theater-historiography.org',
      'www.digitalculture.org',
      'www.digitalrhetoriccollaborative.org',
    ],
    ssl            => false,
    port           => 80,
    docroot        => $docroot,
    manage_docroot => false,
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

  # As with above, SSL is terminated at the load balancer
  apache::vhost { 'publishing-partners-https':
    servername     => 'https://blog.press.umich.edu',
    serveraliases  => [
      'www.theater-historiography.org',
      'www.digitalculture.org',
      'www.digitalrhetoriccollaborative.org',
    ],
    docroot        => $docroot,
    manage_docroot => false,
    ssl            => false,
    port           => 443,
    setenv         => ['HTTPS on'],
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
