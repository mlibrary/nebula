# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::www_lib::vhosts::med
#
# Middle English Dictionary virtual host
#
# @example
#   include nebula::profile::www_lib::vhosts::med
class nebula::profile::www_lib::vhosts::med (
  Array[String] $ip_restrict,
  String $docroot = '/hydra/dromedary-production/current/public',
) {
  $servername = 'med.lib.umich.edu'

  file { "${apache::params::logroot}/dromedary-production":
    ensure => 'directory',
  }

  # Convert string of IPs into directives for custom_fragment
  $ip_restrict_fragment = $ip_restrict.map |$n| { "Require ip ${n}" }.join("\n")

  nebula::apache::www_lib_vhost { 'med-http':
    servername     => $servername,
    docroot        => $docroot,
    logging_prefix => 'dromedary-production/',
    usertrack      => true,

    rewrites       => [
      {
        rewrite_rule => '^(.*)$ https://%{HTTP_HOST}$1 [L,R,NE]'
      },
    ],

    directories    => [
      {
        provider => 'location',
        path     => '/',
        require  => $nebula::profile::www_lib::apache::default_access,
      },
    ],
  }

  nebula::apache::www_lib_vhost { 'med-https':
    servername      => $servername,
    docroot         => $docroot,
    logging_prefix  => 'dromedary-production/',

    ssl             => true,
    port_override   => 443,
    usertrack       => true,

    rewrites        => [
      {
        comment      => 'Serve static assets through apache',
        rewrite_cond => '/hydra/dromedary-production/current/public/$1 -f',
        rewrite_rule => '^/m/middle-english-dictionary(.*)$  /hydra/dromedary-production/current/public$1 [L]',
      },
      {
        comment      => 'Reverse proxy application to app hostname and port',
        rewrite_rule => '^(/m/middle-english-dictionary.*)$ http://app-dromedary-production:30760$1 [P]',
      },
    ],

    directories     => [
      {
        # List of ip addresses used to restrict are converted into a
        # a string and included in the custom_fragment.
        provider        => 'location',
        path            => '/',
        require         => 'all denied',
        custom_fragment => $ip_restrict_fragment,
      },
      {
        provider       => 'directory',
        path           => $docroot,
        options        => 'FollowSymlinks',
        allow_override => 'None',
        require        => $nebula::profile::www_lib::apache::default_access,
      },
    ],

    request_headers => [
      'set X-Forwarded-Proto "https"',
      'set X-Forwarded-Host "quod.lib.umich.edu"',
      'unset Host',
      'unset X-Forwarded-For',
    ],

    headers         => [
      'set "Strict-Transport-Security" "max-age=3600"',
    ],

    custom_fragment => @(EOT)
      # Reverse proxy application to app hostname and port
      ProxyPassReverse /m/middle-english-dictionary http://app-dromedary-production:30760/'
    | EOT
  }
}
