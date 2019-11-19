
# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::apache::redirection
#
# hathitrust.org redirection-only virtual hosts
#
# @example
#   include nebula::profile::hathitrust::apache::redirection
class nebula::profile::hathitrust::apache::redirection (
  String $sdrroot,
  Hash $default_access,
  Array[String] $haproxy_ips,
  Hash $ssl_params,
  String $prefix,
  String $domain,
  Array[String] $alias_domains = []
) {


  $babel_servername   = "${prefix}babel.${domain}"
  $catalog_servername = "${prefix}catalog.${domain}"
  $www_servername     = "${prefix}www.${domain}"


  ['babel', 'catalog', 'm', 'www'].each |String $vhost| {
    $servername = "${prefix}${vhost}.${domain}"

    apache::vhost { "${servername} non-ssl":
      servername        => $servername,
      docroot           => false,
      port              => '80',
      redirect_source   => '/',
      redirect_status   => 'permanent',
      redirect_dest     => "https://${servername}/",
      access_log_file   => "${vhost}/access.log",
      access_log_format => 'combined',
      error_log_file    => "${vhost}/error.log",
    }

    file { "/var/log/apache2/${vhost}":
      ensure => 'directory',
      mode   => '0755',
      owner  => 'root',
      group  => 'root',
    }
  }

  apache::vhost {
    default:
      error_log_file    => 'error.log',
      access_log_file   => 'access.log',
      access_log_format => 'combined',
      docroot           => false;

    'hathitrust canonical name redirection':
      servername      => $domain,
      port            => '80',
      serveraliases   => $alias_domains + $alias_domains.map |$alias_domain| { "www.${alias_domain}" },
      redirect_source => '/',
      redirect_status => 'permanent',
      redirect_dest   => "https://${www_servername}/";

    "m.${catalog_servername} redirection":
      servername      => "m.${catalog_servername}",
      port            => '80',
      redirect_source => '/',
      redirect_status => 'permanent',
      redirect_dest   => "https://m.${prefix}${domain}/";

    "${prefix}m.${domain} https redirection":
      servername => "${prefix}m.${domain}",
      port       => '443',
      rewrites   => [
        {
          rewrite_rule => ["^/?$ https://${www_servername} [last,redirect=permanent]"],
        },
        {
          rewrite_rule => ["^/(.*)$ https://${catalog_servername}/\$1 [last,redirect=permanent]"],
        }
      ],
  }

}
