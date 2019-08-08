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
) {

  ensure_packages(['bsd-mailx'])

  $haproxy_ips = nodes_for_class('nebula::profile::haproxy').map |String $nodename| {
    fact_for($nodename, 'networking')['ip']
  }


  ### MONITORING

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

  $default_access = {
    enforce  => 'all',
    requires => [
      'not env badrobot',
      'not env loadbalancer',
      'all granted'
    ]
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

  apache::mod { 'authz_umichlib':
    package       => 'libapache2-mod-authz-umichlib',
    loadfile_name => 'zz_authz_umichlib.load'
    # TODO: configure
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

  class { 'apache::mod::authz_user': }
  class { 'apache::mod::autoindex': }
  class { 'apache::mod::cgi': }
  apache::mod { 'cosign':
    package => 'libapache2-mod-cosign'
  }
  # FIXME: need to make /var/cosign/filter
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
  class { 'apache::mod::shib': }
  class { 'apache::mod::xsendfile': }


  # TODO we will need more than one of these
  class { 'nebula::profile::ssl_keypair':
    common_name => 'www.lib.umich.edu'
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

  $ssl_params     = {
    ssl            => true,
    ssl_protocol   => '+TLSv1.2',
    ssl_cipher     => 'ECDHE-RSA-AES256-GCM-SHA384',
    ssl_cert       => '/etc/ssl/certs/www.lib.umich.edu.crt',
    ssl_key        => '/etc/ssl/private/www.lib.umich.edu.key',
    ssl_chain      => "/etc/ssl/certs/${chain_crt}"
  }


  # TODO all the vhosts

  # TODO: cron jobs common to all servers
  $vhost_defaults = {
    docroot        => "/www/www.lib/web",
    manage_docroot => false,
    directories    => [
      {
        provider       => 'directory',
        path           => '/www/www.lib/web',
        options        => ['IncludesNOEXEC','Indexes','FollowSymLinks','MultiViews'],
        allow_override => ['AuthConfig','FileInfo','Limit','Options'],
        require        => $default_access
      },
      {
        provider       => 'directory',
        path           => '/',
        allow_override => ['None'],
        options        => ['FollowSymLinks'],
        require        => ''
      },
      {
        provider       => 'directory',
        path           => '/www/www.lib/cgi',
        allow_override => ['None'],
        options        => ['None'],
        require        => $default_access
      }
    ],
    log_level      => 'warn',
    priority       => false # don't prepend a numeric identifier to the vhost
  }

  $cosign_protected_off_paths = [
    ['location','/login'],
    ['location','/vf/vflogin_dbsess.php'],
    ['location','/pk'],
    ['directory','/www/www.lib/cgi/l/login'],
    ['directory','/www/www.lib/cgi/m/medsearch']
  ]

  # http vhosts
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
  }

  $skynet_fragment = @(EOT)
    CookieTracking on
    CookieDomain .lib.umich.edu
    CookieName skynet
  |EOT

  $cosign_locations = [
    {
      provider        => 'location',
      path            => '/cosign/valid',
      handler         => 'cosign',
      custom_fragment => 'CosignProtected Off',
      require         => 'all granted'
    },
    {
      provider => 'location',
      path     =>  '/robots.txt',
      custom_fragment => 'CosignProtected Off',
      require         => 'all granted'
    },
    {
      provider        => 'location',
      path            => '/ctools',
      custom_fragment => 'CosignProtected Off',
      require         => ''
    }
  ]

  $cosign_fragment = @(EOT)
    CosignProtected		On
    CosignHostname		weblogin.umich.edu
    CosignValidReference              ^https?:\/\/[^/]+.umich\.edu(\/.*)?
    CosignValidationErrorRedirect      http://weblogin.umich.edu/cosign/validation_error.html
    CosignCheckIP		never
    CosignRedirect		https://weblogin.umich.edu/
    CosignNoAppendRedirectPort	On
    CosignPostErrorRedirect	https://weblogin.umich.edu/post_error.html
    CosignService		www.lib
    CosignCrypto            /etc/ssl/private/www.lib.umich.edu.key /etc/ssl/certs/www.lib.umich.edu.crt /etc/ssl/certs
    CosignAllowPublicAccess on
  |EOT

  $cosign_public_access_off = @(EOT)
    AuthType cosign
    Require valid-user
    CosignAllowPublicAccess off
  |EOT

  concat::fragment { "www.lib-ssl-cosign":
    target => "www.lib-ssl.conf",
    order  => 59,
    content => $cosign_fragment
  }

  # https vhosts
  apache::vhost {
    default:
      * =>  $vhost_defaults.merge($ssl_params);

   '000-default-ssl':
      port            => 443,
      directories     => [ $monitor_location ] + $vhost_defaults['directories'],
      aliases         => [
        {
          scriptalias => $monitor_path,
          path        => $monitor_dir
        }
      ],
      rewrites =>  [
        {
          rewrite_cond => '%{REQUEST_URI} !^/monitor/monitor.pl',
          rewrite_rule => '^(.*)$ https://%{HTTP_HOST}$1 [L,NE,R]'
        }
      ];

    'www.lib-ssl':
      servername      => 'www.lib.umich.edu',
      port            => 443,
      error_log_file  => 'error.log',

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

      directories     => [
        $cosign_protected_off_paths.map |$provider_path| {
          {
            provider        => $provider_path[0],
            path            => $provider_path[1],
            custom_fragment => $cosign_public_access_off,
            require         => []
          }
        }
      ] + $cosign_locations + $vhost_defaults['directories'],

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
