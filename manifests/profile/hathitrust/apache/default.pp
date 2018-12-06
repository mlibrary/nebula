
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
  $monitor_dir = '/usr/local/lib/cgi-bin/monitor'
  $monitor_location = '/monitor'
  $http_files = lookup('nebula::http_files')

  $requires = {
    enforce  => 'any',
    requires => [ 'local' ] + $haproxy_ips.map |String $ip| { "require ip ${ip}" }
  }

  file { "${monitor_dir}/monitor.pl":
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => "https://${http_files}/ae-utils/bins/monitor.pl"
  }

  apache::vhost { 'default non-ssl':
    servername         => 'localhost',
    port               => 80,

    rewrites           => [
      {
        rewrite_rule => "^(/$|/index.html$) https://${servername}/cgi/mb    [redirect=permanent,last]"
      }
    ],

    aliases            => [
      {
        scriptalias => $monitor_location,
        path        => $monitor_dir
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
        requires       => $requires
      },

      {
        provider       => 'directorymatch',
        path           => "^(${docroot}/(([^/]+)/(web|cgi)|widgets/([^/]+)/web|cache|mdp-web)/|/tmp/fastcgi/)(.*)",
        allow_override => ['None'],
        requires       => $requires
      },

      {
        provider => 'location',
        path     => '/monitor',
        requires => $requires
      },

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
