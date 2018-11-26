
# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::apache::default
#
# hathitrust.org default virtual host
#
# @example
#   include nebula::profile::hathitrust::apache::default
class nebula::profile::hathitrust::apache::default (
  String $sdrroot,
  Hash $default_access,
  Array[String] $haproxy_ips,
  Hash $ssl_params,
  String $prefix,
  String $domain,
) {

  $servername = "${prefix}babel.${domain}"
  $docroot = $sdrroot

  apache::vhost { 'default non-ssl':
    servername         => 'localhost',
    port               => 80,

    rewrites           => [
      {
        rewrite_rule => "^(/$|/index.html$) https://${servername}/cgi/mb    [redirect=permanent,last]"
      }
    ],

    directoryindex     => 'index.html',
    directories        => [
      {
        provider => 'filesmatch',
        location =>  '~$',
        require  => 'all denied'
      },

      {
        provider       => 'directory',
        location       => '/',
        allow_override => ['None'],
        requires       =>  {
          enforce  => 'any',
          requires => [ 'local' ] + $haproxy_ips.map |String $ip| { "require ip ${ip}" }
        }
      },

      {
        provider       => 'directorymatch',
        path           => "^(${docroot}/(([^/]+)/(web|cgi)|widgets/([^/]+)/web|cache|mdp-web)/|/tmp/fastcgi/)(.*)",
        allow_override => ['None'],
        requires       => {
          enforce  => 'any',
          # TODO: also allow grog (nebula::role::hathitrust::dev::app_host),
          # squishees (currently nebula::role::hathitrust::prod; need a solr
          # role)
          requires => ['local'] + $haproxy_ips.map |String $ip| { "require ip ${ip}" }
        }
      }

    ],
    manage_docroot     => false,
    docroot            => $docroot,

    setenvif           => [
      'Remote_Addr "::1" loopback',
      'Remote_Addr "127.0.0.1" loopback'
    ],
    access_log_file    => 'access.log',
    access_log_format  => 'combined',
    access_log_env_var => 'env=!loopback',
    error_log_file     => 'error.log'
  }
}
