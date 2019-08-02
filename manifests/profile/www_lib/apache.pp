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
  class { 'apache::mod::authz_user': }
  class { 'apache::mod::autoindex': }
  class { 'apache::mod::cgi': }
  apache::mod { 'cosign':
    package => 'libapache2-mod-cosign'
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
  $vhost_defaults = {
    docroot        => "/www/www.lib/web",
    manage_docroot => false,
    directories    => [
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
    log_level      => 'warn',
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

  $cosign_fragment = @(EOT)
    CosignProtected		On
    CosignHostname		weblogin.umich.edu
    # new for v.3:
    CosignValidReference              ^https?:\/\/[^/]+.umich\.edu(\/.*)?
    CosignValidationErrorRedirect      http://weblogin.umich.edu/cosign/validation_error.html
    <Location /cosign/valid>
      SetHandler          cosign
      CosignProtected     Off
      Allow from all
      Satisfy any
    </Location>
    <Location /robots.txt>
      CosignProtected     Off
      Allow from all
      Satisfy any
    </Location>
    # end new stuff for v.3
    CosignCheckIP		never
    CosignRedirect		https://weblogin.umich.edu/
    CosignNoAppendRedirectPort	On
    CosignPostErrorRedirect	https://weblogin.umich.edu/post_error.html
    CosignService		www.lib
    CosignCrypto            /etc/ssl/private/www.lib.umich.edu.key /etc/ssl/certs/www.lib.umich.edu.crt /etc/ssl/certs
    <Location "/ctools">
    CosignProtected     Off
    </Location>

    CosignAllowPublicAccess on
  |EOT

  # https vhosts
  apache::vhost {
    default:
      * =>  $vhost_defaults.merge($default_vhost_params['ssl_params']);

   '000-default-ssl':
      redirect_source => '/',
      redirect_dest   => 'https://www.lib.umich.edu/',
      port => 443;

    'www.lib ssl':
      servername      => 'www.lib.umich.edu',
      port            => 443,

      access_logs     => [
        {
          file => 'error.log',
          format => 'combined'
        },
        {
          file => 'clickstream.log',
          format => 'usertrack'
        },
      ],


      custom_fragment => join([$cosign_fragment, $skynet_fragment],"\n"),

      directories     => [
        $cosign_protected_off_paths.map |$provider_path| {
          {
            provider        => $provider_path[0],
            path            => $provider_path[1],
            custom_fragment => 'CosignAllowPublicAccess off'
          }
        }
      ] + $vhost_defaults['directories'],

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
