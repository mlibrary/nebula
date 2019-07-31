# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::www_lib::apache
#
# Install apache for www_lib applications
#
# @example
#   include nebula::profile::www_lib::apache
class nebula::profile::www_lib::apache (
  String $prefix = '',
  String $domain = 'www.lib.umich.edu',
) {

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

  $staff_networks = lookup('www_lib::networks::staff', default_value => []).flatten.unique.map |$network| {
    "ip ${network['block']}"
  }.sort

  class { 'apache':
    default_vhost          => false,
    default_ssl_vhost      => false,
    timeout                => 300,
    keepalive_timeout      => 2,
    log_formats            => {
      vhost_combined => '%v:%p %a %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\" %D',
      combined       => '%a %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\" %D'
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
    minspareservers        => 5,
    maxspareservers        => 10,
    maxrequestworkers      => 256,
    maxconnectionsperchild => 1000
  }

  # Modules enabled
  #
  apache::mod { ['access_compat','asis','authz_groupfile','usertrack']: }
  # TODO class { 'apache::mod::actions' }
  class { 'apache::mod::auth_basic': }
  class { 'apache::mod::authn_file': }
  class { 'apache::mod::authn_core': }
  apache::mod { 'authz_umichlib':
    package =>  'libapache2-mod-authz-umichlib',
    # TODO: configure
  }
  class { 'apache::mod::authz_user': }
  class { 'apache::mod::autoindex': }
  # TODO configure mod_autoindex??
  class { 'apache::mod::cgi': }
  apache::mod { 'cosign':
    package => 'libapache2-mod-cosign'
  }
  class { 'apache::mod::deflate': }
  # TODO configure mod_deflate??
  class { 'apache::mod::dir':
    # TODO configuration
    indexes => ['index.html']
  }
  class { 'apache::mod::env': }
  class { 'apache::mod::headers': }
  class { 'apache::mod::include': }
  # mod_jk is going away - torquebox retirement
  class { 'apache::mod::mime': }
  class { 'apache::mod::negotiation': }
  # use exclusively FPM instead?
  #  class { 'apache::mod::php':
  #    extensions => ['.php','.phtml']
  #  }
  class { 'apache::mod::proxy': }
  class { 'apache::mod::proxy_fcgi': }
  class { 'apache::mod::proxy_http': }
  class { 'apache::mod::remoteip':
    header    => 'X-Client-IP',
    proxy_ips => $haproxy_ips
  }
  class { 'apache::mod::reqtimeout': }
  # TODO configure
  class { 'apache::mod::setenvif': }
  # not in rdist, but used?
  class { 'apache::mod::shib': }
  class { 'apache::mod::xsendfile': }


  # TODO we will need more than one of these
  class { 'nebula::profile::ssl_keypair':
    common_name => 'www.lib.umich.edu'
  }

  apache::custom_config { 'ip-detection':
    source => 'puppet:///apache/ip-detection.conf'
  }

  apache::custom_config { 'badrobots':
    source => 'puppet:///apache/badrobots.conf'
  }

  file { '/etc/apache2/conf-enabled':
    ensure  => 'directory',
    recurse => true,
    force   => true,
    purge   => true
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
    default_access => $default_access,
    haproxy_ips    => $haproxy_ips,
    ssl_params     => {
      ssl            => true,
      ssl_protocol   => '+TLSv1.2',
      ssl_cipher     => 'ECDHE-RSA-AES256-GCM-SHA384',
      ssl_cert       => '/etc/ssl/certs/www.lib.umich.edu.crt',
      ssl_key        => '/etc/ssl/private/www.lib.umich.edu.key',
      ssl_chain      => "/etc/ssl/certs/${chain_crt}"
    },
    prefix         => $prefix,
    domain         => $domain
  }


  # TODO all the vhosts

  # TODO: cron jobs common to all servers
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
