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
  String $auth_dbd_params,
  String $prefix = '',
  String $domain = 'www.lib.umich.edu',
  String $chain_crt = 'incommon_sha2.crt',
) {

  ensure_packages(['bsd-mailx'])

  $haproxy_ips = nodes_for_class('nebula::profile::haproxy').map |String $nodename| {
    fact_for($nodename, 'networking')['ip']
  }


  ### MONITORING ########################################

  # extract to separate profile?

  $monitor_path = '/monitor'
  $monitor_location = {
    provider => 'location',
    path     => $monitor_path,
    require  => {
      enforce  => 'any',
      requires => [ 'local' ] + $haproxy_ips.map |String $ip| { "ip ${ip}" }
    }
  }

  $cgi_dir = '/usr/local/lib/cgi-bin'
  $monitor_dir = "${cgi_dir}/monitor"

  file { $cgi_dir:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755'
  }


  class { 'nebula::profile::monitor_pl':
    directory  => $monitor_dir,
    shibboleth => true,
    solr_cores => lookup('nebula::www_lib::monitor::solr_cores'),
    mysql      => lookup('nebula::www_lib::monitor::mysql')
  }

  #####################################################

  $ssl_chain = "/etc/ssl/certs/${chain_crt}"

  file { $ssl_chain:
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    notify => Class['Apache::Service'],
    source => "puppet:///ssl-certs/${chain_crt}"
  }


  class { 'apache':
    default_vhost          => false,
    default_ssl_vhost      => false,
    default_ssl_chain      => $ssl_chain,
    timeout                => 300,
    keepalive_timeout      => 2,
    log_formats            => {
      vhost_combined => '%v:%p %a %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\" %D',
      combined       => '%a %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\" %D',
      usertrack      => '{\"user\":\"%u\",\"session\":\"%{skynet}C\",\"request\":\"%r\",\"time\":\"%t\",\"domain\":\"%V\"}'
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
  class { 'apache::mod::auth_basic': }
  class { 'apache::mod::authn_file': }
  class { 'apache::mod::authn_core': }
  class { 'apache::mod::dbd': }


  ###### extract to authz_umichlib profile? ################################

  apache::mod { 'authz_umichlib':
    package       => 'libapache2-mod-authz-umichlib',
    loadfile_name => 'zz_authz_umichlib.load'
  }

  file { 'authz_umichlib.conf':
    ensure  => file,
    path    => "${::apache::mod_dir}/authz_umichlib.conf",
    mode    => $::apache::file_mode,
    content => template('nebula/profile/www_lib/authz_umichlib.conf.erb'),
    require => Exec["mkdir ${::apache::mod_dir}"],
    before  => File[$::apache::mod_dir],
    notify  => Class['apache::service'],
  }

  file_line { '/etc/apache2/envvars ORACLE_HOME':
    ensure => 'present',
    line   => "export ORACLE_HOME=/etc/oracle",
    match  => "/^export ORACLE_HOME=/",
    path   => '/etc/apache2/envvars'
  }

  ##########################################################################

  class { 'apache::mod::authz_user': }
  class { 'apache::mod::autoindex': }
  class { 'apache::mod::cgi': }
  apache::mod { 'cosign':
    package => 'libapache2-mod-cosign'
  }

  file { '/var/cosign/filter':
    ensure => 'directory',
    owner   => 'nobody',
    group  => 'nogroup'
  }

  class { 'apache::mod::deflate': }
  class { 'apache::mod::dir':
    indexes => ['index.html','index.htm','index.php','index.phtml','index.shtml']
  }
  class { 'apache::mod::env': }
  class { 'apache::mod::headers': }
  class { 'apache::mod::include': }
  class { 'apache::mod::mime': }
  class { 'apache::mod::negotiation': }
  class { 'apache::mod::php':
    # we'll configure php 7.3 separately
    package_name => 'libapache2-mod-php5.6',
    extensions   => ['.php','.phtml'],
    php_version  => "5.6"
  }
  class { 'apache::mod::proxy': }
  class { 'apache::mod::proxy_fcgi': }
  class { 'apache::mod::proxy_http': }
  class { 'apache::mod::remoteip':
    header    => 'X-Client-IP',
    proxy_ips => $haproxy_ips
  }
  class { 'apache::mod::reqtimeout': }
  class { 'apache::mod::setenvif': }
  # causes apparent conflicts with cosign; to be resolved later
  #  class { 'apache::mod::shib': }
  class { 'apache::mod::xsendfile': }

  @nebula::apache::ssl_keypair { 'www.lib.umich.edu': }

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

  apache::listen { ['80','443']: }


  # TODO: cron jobs common to all servers

  nebula::apache::www_lib_vhost { '000-default':
    ssl        => false,
    servername => 'www.lib.umich.edu',
    rewrites   => [
      {
        # redirect all access to https except monitoring
        rewrite_cond => '%{REQUEST_URI} !^/monitor/monitor.pl',
        rewrite_rule => '^(.*)$ https://%{HTTP_HOST}$1 [L,NE,R]'
      }
    ];
  }

  $skynet_fragment = @(EOT)
    CookieTracking on
    CookieDomain .lib.umich.edu
    CookieName skynet
  |EOT

  # https vhosts
  nebula::apache::www_lib_vhost { '000-default-ssl':
    ssl         => true,
    ssl_cn      => 'www.lib.umich.edu',
    servername  => $::fqdn,
    directories => [ $monitor_location ],
    aliases     => [
      {
        scriptalias => $monitor_path,
        path        => $monitor_dir
      }
    ],
    rewrites    => [
      {
        rewrite_cond => '%{REQUEST_URI} !^/monitor/monitor.pl',
        rewrite_rule => '^(.*)$ https://%{HTTP_HOST}$1 [L,NE,R]'
      }
    ];
  }

  nebula::apache::www_lib_vhost { 'www.lib-ssl':
    servername      => 'www.lib.umich.edu',
    ssl             => true,
    error_log_file  => 'error.log',
    cosign          => true,
    cosign_public_access_off_dirs => [
      {
        provider => 'location',
        path     => '/login'
      },
      {
        provider => 'location',
        path     => '/vf/vflogin_dbsess.php'
      },
      {
        provider => 'location',
        path     => '/pk',
      },
      {
        provider => 'directory',
        path     => '/www/www.lib/cgi/l/login',
      },
      {
        provider => 'directory',
        path     => '/www/www.lib/cgi/m/medsearch'
      }
    ],

    access_logs     => [
      {
        file => 'access.log',
        format => 'combined'
      },
      {
        file => 'clickstream.log',
        format => 'usertrack'
      },
    ],

    custom_fragment => $skynet_fragment,

    # TODO: hopefully these can all be removed
    rewrites        => [
      {
        # rewrite for wsfh
        #
        # remote after 2008-12-31
        #
        # jhovater - 2008-12-04 varnum said to keep
        # 2008-08-28 csnavely per varnum
        rewrite_rule =>  '^/wsfh		http://www.wsfh.org/	[redirect,last]'
      },
      {
        # rewrites for aol-like, tinyurl-like "go" function
        #
        # 2007-05 csnavely
        # 2013-01-23 keep for drupal7 - aelkiss per bertrama
        rewrite_rule => '^/go/pubmed  http://searchtools.lib.umich.edu/V?func=native-link&resource=UMI01157 [redirect,last]'
      },
      {
        # Redirect Islamic Manuscripts to the Lib Guides.
        #
        # Check with nancymou and ekropf for potential removal after 2016-09-01
        #
        # 2016-08-29 skorner per nancymou
        rewrite_rule => '^/islamic	http://guides.lib.umich.edu/islamicmss/find 	[redirect=permanent,last]'
      },
    ];
  }


}
