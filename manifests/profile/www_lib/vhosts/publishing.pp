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
    servername => 'www.publishing.umich.edu',
    ssl        => false,
    port       => 80,
    docroot    => $docroot,
    rewrites   => [
      {
        rewrite_rule => '^(.*)$ https://%{HTTP_HOST}$1 [L,NE,R]'
      },
    ],
  }

  # Note that this vhost listens on 443 but is HTTP, because HAProxy terminates
  # SSL. We pass an ENV var to signal that the request is over HTTPS for app
  # URL generation, etc.
  apache::vhost { 'www.publishing-https':
    servername      => 'https://www.publishing.umich.edu',
    docroot         => $docroot,
    ssl             => false,
    port            => 443,
    setenv          => ['HTTPS on'],
    setenvifnocase  => '^Authorization$ "(.+)" HTTP_AUTHORIZATION=$1',
    directories     => [
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
    # Redirects from legacy URLs, expire 09-01-2020
    redirect_source => [
      '/publications/journals',
      '/publications/digital-projects',
      '/publications/textbooks',
      '/publications/books',
      '/publications/conference-volumes',
      '/publications/reprints',
      '/blog',
      '/about/contact-information',
      '/about/our-organization',
      '/services/copyright-services',
      '/services/journal-services',
      '/services/repository-services',
      '/um-press',
    ],
    redirect_dest   => [
      'http://www.publishing.umich.edu/journals',
      'http://www.publishing.umich.edu/publications/#digital-projects',
      'http://www.publishing.umich.edu/publications',
      'http://www.publishing.umich.edu/publications/#imprints',
      'http://www.publishing.umich.edu/publications/#conference-volumes',
      'http://www.publishing.umich.edu/publications/#reprints',
      'http://www.publishing.umich.edu/news',
      'http://www.publishing.umich.edu/#contact',
      'http://www.publishing.umich.edu/about',
      'http://www.lib.umich.edu/copyright',
      'http://www.publishing.umich.edu/journals',
      'http://deepblue.lib.umich.edu',
      'http://www.press.umich.edu',
    ],
  }

  # A range of other sites served under the same Wordpress installation
  apache::vhost { 'publishing-partners-http':
    servername    => 'www.textcreationpartnership.org',
    serveraliases => [
      'blog.press.umich.edu',
      'www.theater-historiography.org',
      'www.digitalculture.org',
      'www.digitalrhetoriccollaborative.org',
    ],
    ssl           => false,
    port          => 80,
    docroot       => $docroot,
    directories   => [
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
    servername    => 'https://www.textcreationpartnership.org',
    serveraliases => [
      'blog.press.umich.edu',
      'www.theater-historiography.org',
      'www.digitalculture.org',
      'www.digitalrhetoriccollaborative.org',
    ],
    docroot       => $docroot,
    ssl           => false,
    port          => 443,
    setenv        => ['HTTPS on'],
    directories   => [
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
