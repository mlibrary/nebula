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
  String $monitoring_user = 'haproxyctl',
  Optional[Hash] $monitoring_pubkey = undef
) {


  if($monitoring_pubkey) {
    nebula::authzd_user { $monitoring_user:
      gid  => 'nogroup',
      home => '/nonexistent',
      key  => $monitoring_pubkey
    }
  }

  ensure_packages(['bsd-mailx'])

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
      combined => '%a %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %v \"%{X-HathiTrust-InCopyright}o\" %D'
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
    conf_enabled           => '/etc/apache2/conf-enabled',
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
  class { 'apache::mod::deflate':
    types => [
      'text/html',
      'text/plain',
      'text/xml',
      'text/css',
      'application/javascript',
      'application/xml',
      'application/xhtml+xml',
      'application/json',
      'image/svg+xml'
    ],
  }
  class { 'apache::mod::expires':
    expires_active  =>  'true',
    expires_by_type => [
      { 'application/javascript' => 'access plus 6 hours' },
      { 'text/css' => 'access plus 6 hours' }
    ],
    expires_default => 'modification plus 2 hours'
  }
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

  class { 'nebula::profile::ssl_keypair':
    common_name => 'www.hathitrust.org'
  }

  apache::custom_config { 'ip-detection':
    source => 'puppet:///apache/ip-detection.conf'
  }

  apache::custom_config { 'badrobots':
    source => 'puppet:///apache/badrobots.conf'
  }

  file { '/etc/apache2/conf-available':
    ensure => 'absent',
    force  => true,
    purge  => true
  }

  file { '/etc/logrotate.d/apache2':
    ensure  => file,
    content => template('nebula/profile/apache/logrotate.d/apache2.erb'),
  }

  $chain_crt = lookup('nebula::profile::ssl_keypair::chain_crt')

  $default_vhost_params = {
    sdrroot        => $sdrroot,
    default_access => $default_access,
    haproxy_ips    => $haproxy_ips,
    ssl_params     => {
      ssl            => true,
      ssl_protocol   => '+TLSv1.2',
      ssl_cipher     => 'ECDHE-RSA-AES256-GCM-SHA384',
      ssl_cert       => '/etc/ssl/certs/www.hathitrust.org.crt',
      ssl_key        => '/etc/ssl/private/www.hathitrust.org.key',
      ssl_chain      => "/etc/ssl/certs/${chain_crt}"
    },
    prefix         => $prefix,
    domain         => $domain
  }


  ['redirection','babel','www','catalog'].each |$vhost| {
    class { "${title}::${vhost}":
      * =>  $default_vhost_params
    }
  }

  cron { 'apache connection count check':
    command => '/usr/local/bin/ckapacheconn',
    user    => 'root',
    minute  => '*/15',
  }

  $http_files = lookup('nebula::http_files')
  file { '/usr/local/bin/ckapacheconn':
    ensure => 'present',
    mode   => '0755',
    source => "https://${http_files}/ae-utils/bins/ckapacheconn"
  }

  cron { 'apache restart':
    command => '( /bin/systemctl stop apache2; /bin/sleep 10; /bin/systemctl start apache2 ) > /dev/null',
    user    => 'root',
    minute  => '1',
    hour    => '0',
  }

}
