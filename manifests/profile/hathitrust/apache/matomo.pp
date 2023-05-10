# Copyright (c) 2018, 2019, 2023 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::apache::matomo
#
# matomo.hathitrust.org virtual host
#
# @example
#   include nebula::profile::hathitrust::apache::matomo
class nebula::profile::hathitrust::apache::matomo (
  String $sdrroot,
  Hash $default_access,
  Array[String] $haproxy_ips,
  Hash $ssl_params,
  String $prefix,
  String $domain,
  String $matomo_endpoint,
  String $subdomain = 'matomo.www',
) {

  ### client cert

  $certname = $trusted['certname'];
  $client_cert = "/etc/ssl/private/${certname}.pem";

  ## VHOST DEFINITION

  $servername = "${subdomain}.${domain}"

  file { '/var/log/apache2/matomo':
    ensure => 'directory',
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

  apache::vhost { "${servername} ssl":
    servername                  => $servername,
    use_canonical_name          => 'On',
    port                        => '443',
    docroot                     => $sdrroot,
    manage_docroot              => false,
    error_log_file              => 'matomo/error.log',
    access_log_file             => 'matomo/access.log',
    access_log_format           => 'combined',
    *                           => $ssl_params,

    # from babel-common

    aliases                     => [
      {
        aliasmatch => '^/robots.txt$',
        path       => "${sdrroot}/common/web/robots.txt"
      },
      {
        aliasmatch => '^/favicon.ico$',
        path       => "${sdrroot}/common/web/favicon.ico"
      },
    ],

    directories                 => [
      {
        provider => 'filesmatch',
        location =>  '~$',
        require  => 'all denied'
      },
      {
        provider       => 'directory',
        location       => $sdrroot,
        allow_override => ['None'],
        require        =>  'all denied'
      },
      {
        provider   => 'location',
        path       => '/',
        proxy_pass => [ { url =>$matomo_endpoint }],
      },
    ],

    ssl_proxyengine             => true,
    ssl_proxy_check_peer_name   => 'on',
    ssl_proxy_check_peer_expire => 'on',
    ssl_proxy_machine_cert      => $client_cert,

    request_headers             => [
      # Setting remote user for 2.4
      'set X-Remote-User "expr=%{REMOTE_USER}"',
      # Fix redirects being sent to non ssl url (https -> http)
      'set X-Forwarded-Proto "https"',
      # Remove existing X-Forwarded-For headers; mod_proxy will automatically add the correct one.
      'unset X-Forwarded-For',
    ],

  }

}
