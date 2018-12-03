# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::apache
#
# Install apache for HathiTrust applications
#
# @example
#   include nebula::profile::hathitrust::apache
class nebula::profile::hathitrust::apache (
  String $prefix = '',
  String $domain = 'hathitrust.org',
  String $sdrroot = '/htapps/babel',
) {

  $default_access = {
    enforce  => 'all',
    requires => [
      'not env badrobot',
      'not env loadbalancer',
      'all granted'
    ]
  }

  $haproxy_ips = nodes_for_class('nebula::profile::haproxy').map |String $nodename| {
    fact_for($nodename, 'networking')['ip']
  }

  $staff_networks = lookup('hathitrust::networks::staff', default_value => []).flatten.unique.map |$network| {
    "ip ${network['block']}"
  }.sort

  class { 'apache':
    default_vhost          => false,
    default_ssl_vhost      => false,
    timeout                => 900,
    keepalive_timeout      => 2,
    log_formats            => {
      combined => '%a %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %v \"%{X-HathiTrust-InCopyright}o\"'
    },
    # configured below by explicitly declaring params for apache::mod::prefork class
    mpm_module             => false,
    serveradmin            => 'lit-ae-systems@umich.edu',
    servername             => $domain,
    trace_enable           => 'Off',
    root_directory_secured => true,
    scriptalias            => undef,
    docroot                => false,
    default_mods           => false,
    user                   => 'nobody',
    group                  => 'nogroup',
  }

  class { 'apache::mod::prefork':
    startservers           => 10,
    minspareservers        => 10,
    maxspareservers        => 15,
    maxrequestworkers      => 256,
    maxconnectionsperchild => 0
  }

  # Modules enabled
  #
  apache::mod { 'access_compat': }
  class { 'apache::mod::authn_core': }
  class { 'apache::mod::autoindex': }
  class { 'apache::mod::cgi': }
  class { 'apache::mod::dir':
    indexes => ['index.html']
  }
  class { 'apache::mod::expires': }
  class { 'apache::mod::include': }
  class { 'apache::mod::mime_magic': }
  class { 'apache::mod::negotiation': }
  class { 'apache::mod::php':
    extensions => ['.php','.phtml']
  }
  class { 'apache::mod::proxy_fcgi': }
  class { 'apache::mod::reqtimeout': }
  class { 'apache::mod::shib': }

  class { 'apache::mod::remoteip':
    header    => 'X-Client-IP',
    proxy_ips => $haproxy_ips
  }

  class { 'apache::mod::status':
    requires => {
      enforce  => 'any',
      requires => [ 'local' ] + $staff_networks
    }
  }

  $ssl_cert = '/etc/ssl/certs/www.hathitrust.org.crt'
  $ssl_key = '/etc/ssl/private/www.hathitrust.org.key'
  $ssl_chain = '/etc/ssl/certs/incommon_sha2.crt'

  file { $ssl_cert:
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    notify => Class['Apache::Service'],
    source => 'puppet:///ssl-certs/www.hathitrust.org.crt'
  }

  file { $ssl_chain:
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    notify => Class['Apache::Service'],
    source => 'puppet:///ssl-certs/incommon_sha2.crt'
  }

  file { $ssl_key:
    mode   => '0600',
    owner  => 'root',
    group  => 'root',
    notify => Class['Apache::Service'],
    source => 'puppet:///ssl-certs/www.hathitrust.org.key'
  }

  apache::custom_config { 'ip-detection':
    source => 'puppet:///apache/ip-detection.conf'
  }

  apache::custom_config { 'badrobots':
    source => 'puppet:///apache/badrobots.conf'
  }

  file { '/etc/apache2/conf-enabled':
    ensure => 'absent',
    force  => true,
    purge  => true
  }

  file { '/etc/apache2/conf-available':
    ensure => 'absent',
    force  => true,
    purge  => true
  }


  $default_vhost_params = {
    sdrroot        => $sdrroot,
    default_access => $default_access,
    haproxy_ips    => $haproxy_ips,
    ssl_params     => {
      ssl            => true,
      ssl_protocol   => '+TLSv1.2',
      ssl_cipher     => 'ECDHE-RSA-AES256-GCM-SHA384',
      ssl_cert       => $ssl_cert,
      ssl_key        => $ssl_key,
      ssl_chain      => $ssl_chain,
    },
    prefix         => $prefix,
    domain         => $domain
  }


  ['default','redirection','babel','www','catalog'].each |$vhost| {
    class { "${title}::${vhost}":
      * =>  $default_vhost_params
    }
  }

}
