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
  #    extensions                                                    => ['.php','.phtml']
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

  apache::listen { ['80','443']: }

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

  $vhost_defaults = {
    docroot     => "/www/www.lib/web",
    directories => [
      {
        provider => 'directory',
        path     => '/www/www.lib/web',
        options  => ['IncludesNOEXEC','Indexes','FollowSymLinks','MultiViews'],
        allow_override => ['AuthConfig','FileInfo','Limit','Options']
      },
      {
        provider       => 'directory',
        path           => '/',
        allow_override => ['None'],
        options        => ['FollowSymLinks']
      },
      {
        provider       => 'directory',
        path           => '/www/www.lib/cgi',
        allow_override => ['None'],
        options        => ['None'],
        require        => $default_access
      }
    ],
    log_level   =>  'warn'
  }

  $cosign_protected_off_paths = [
    ['location','/login'],
    ['location','/vf/vflogin_dbsess.php'],
    ['location','/pk'],
    ['directory','/www/www.lib/cgi/l/login'],
    ['directory','/www/www.lib/cgi/m/medsearch'] 
  ]

  apache::vhost { 
    default:
      * =>  $vhost_defaults;
    
    '000-default':
      port       => 80,
      servername => 'www.lib.umich.edu',
      docroot    => '/www/www.lib/web',
      rewrites   => [
        {
          # redirect all access to https except monitoring
          rewrite_cond => '%{REQUEST_URI} !^/monitor/monitor.pl',
          rewrite_rule => '^(.*)$ https://%{HTTP_HOST}$1 [L,NE,R]'
        }
      ];

   '000-default-ssl':
      # TODO ssl config
      redirect_source => '/',
      redirect_dest   => 'https://www.lib.umich.edu/',
      port => 443;

    'www.lib ssl':
      servername  => 'www.lib.umich.edu',
      port        => 443,
      # Use logging ""
      # Use logging_user ""
      # Use cosign "www.lib" "www.lib.umich.edu.key" "www.lib.umich.edu.crt"
      # CosignAllowPublicAccess on


      directories => [
        $cosign_protected_off_paths.map |$provider_path| {
          {
            provider        => $provider_path[0],
            path            => $provider_path[1],
            custom_fragment => 'CosignAllowPublicAccess off'
          }
        }
      ] + $vhost_defaults['directories'],

      # TODO: hopefully these can all be removed
      rewrites    => [
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
