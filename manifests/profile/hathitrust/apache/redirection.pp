
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
  String $ssl_cert,
  String $ssl_key,
  String $ssl_chain,
  String $prefix,
  String $domain,
  Array[String] $alias_domains = []
) {


  $babel_servername = "${prefix}babel.${domain}"
  $www_servername = "${prefix}www.${domain}"


  ['babel', 'catalog', 'm', 'www'].each |String $vhost| {
    apache::vhost { "${prefix}${vhost}.${domain} non-ssl":
      servername        => $vhost,
      docroot           => false,
      port              => '80',
      redirect_source   => '/',
      redirect_status   => 'permanent',
      redirect_dest     => "https://${prefix}${vhost}.${domain}",
      access_log_file   => "${vhost}/access.log",
      access_log_format => 'combined',
      error_log_file    => "${vhost}/error.log"
    }

    file { "/var/log/apache2/${vhost}":
      ensure => 'directory',
      mode   => '0755',
      owner  => 'root',
      group  => 'root',
    }
  }


  apache::vhost { 'hathitrust canonical name redirection':
    servername        => $domain,
    docroot           => false,
    port              => '80',
    # TODO test me
    serveraliases     => $alias_domains + $alias_domains.map |$alias_domain| { "www.${alias_domain}" },
    redirect_source   => '/',
    redirect_status   => 'permanent',
    redirect_dest     => "https://${www_servername}",
    error_log_file    => 'error.log',
    access_log_file   => 'access.log',
    access_log_format => 'combined',
  }

  # TODO: should this be present in an ssl version? is it still necessary?
  apache::vhost { "m.${babel_servername} redirection":
    servername        => "m.${babel_servername}",
    port              => '80',
    docroot           => false,
    rewrites          => [
      # is skin=mobile argument present?
      {
        # yes, just redirect
        rewrite_cond => '%{QUERY_STRING} skin=mobile         [nocase]',
        rewrite_rule => "/(.*)    https://${babel_servername}/\$1     [last,redirect]",
      },
      {
        # no, prepend it
        rewrite_cond => '%{QUERY_STRING} !skin=mobile          [nocase]',
        rewrite_rule => "^/(.*)    https://${babel_servername}/\$1?skin=mobile [last,redirect,qsappend]"
      }
    ],
    error_log_file    => 'error.log',
    access_log_file   => 'access.log',
    access_log_format => 'combined',
  }

  # TODO: should this be present in an ssl version? is it still necessary?
  apache::vhost { 'mdp.lib.umich.edu redirection':
    servername        => 'mdp.lib.umich.edu',
    serveraliases     => ['sdr.lib.umich.edu'],
    port              => '80',
    docroot           => false,
    redirect_dest     => "https://${babel_servername}",
    redirect_source   => '/',
    redirect_status   => 'permanent',
    error_log_file    => 'error.log',
    access_log_file   => 'access.log',
    access_log_format => 'combined',
  }
}
