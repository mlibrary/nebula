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
  String $ssl_cn = $domain,
  String $vhost_root = "/www/www.lib"
) {

  ensure_packages(['bsd-mailx'])

  class { 'nebula::profile::apache':
    log_formats => {
      vhost_combined => '%v:%p %a %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\" %D',
      combined       => '%a %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\" %D',
      usertrack      => '{\"user\":\"%u\",\"session\":\"%{skynet}C\",\"request\":\"%r\",\"time\":\"%t\",\"domain\":\"%V\"}'
    }
  }

  include nebula::profile::apache::monitoring

  class { 'nebula::profile::monitor_pl':
    directory  => $nebula::profile::apache::monitoring::monitor_dir,
    shibboleth => true,
    solr_cores => lookup('nebula::www_lib::monitor::solr_cores'),
    mysql      => lookup('nebula::www_lib::monitor::mysql')
  }

  apache::mod { ['access_compat','asis','authz_groupfile','usertrack']: }
  include apache::mod::auth_basic
  include apache::mod::authn_file
  include apache::mod::authn_core
  include apache::mod::authz_user
  include apache::mod::autoindex
  include apache::mod::cgi
  include apache::mod::deflate

  class { 'apache::mod::dir':
    indexes => ['index.html','index.htm','index.php','index.phtml','index.shtml']
  }

  include apache::mod::env
  include apache::mod::headers
  include apache::mod::include
  include apache::mod::mime
  include apache::mod::negotiation

  class { 'apache::mod::php':
    # we'll configure php 7.3 separately
    package_name => 'libapache2-mod-php5.6',
    extensions   => ['.php','.phtml'],
    php_version  => "5.6"
  }

  include apache::mod::proxy
  include apache::mod::proxy_fcgi
  include apache::mod::proxy_http
  include apache::mod::reqtimeout
  include apache::mod::setenvif
  # causes apparent conflicts with cosign; to be resolved later
  #  class { 'apache::mod::shib': }
  include apache::mod::xsendfile

  include nebula::profile::apache::authz_umichlib
  include nebula::profile::apache::cosign

  # should be moved elsewhere to include as virtual all that might be present on the puppet master
  @nebula::apache::ssl_keypair { $ssl_cn: }
  @nebula::apache::ssl_keypair { 'www.theater-historiography.org': }
  nebula::apache::redirect_vhost_https { 'theater-historiography.org':
    ssl_cn        => 'www.theater-historiography.org',
    serveraliases => [
      'www.theater-historiography.com',
      'theater-historiography.com',
      'www.theatre-historiography.com',
      'theatre-historiography.com',
      'www.theatre-historiography.org',
      'theatre-historiography.org',
    ],
  }

  # TODO: cron jobs common to all servers

  nebula::apache::www_lib_vhost { '000-default':
    ssl        => false,
    ssl_cn     => $ssl_cn,
    servername => "$prefix$domain",
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
    ssl_cn      => $ssl_cn,
    servername  => $::fqdn,
    directories => [ $nebula::profile::apache::monitoring::location ],
    aliases     => [ $nebula::profile::apache::monitoring::scriptalias ],
    rewrites    => [
      {
        rewrite_cond => '%{REQUEST_URI} !^/monitor/monitor.pl',
        rewrite_rule => '^(.*)$ https://%{HTTP_HOST}$1 [L,NE,R]'
      }
    ];
  }

  nebula::apache::www_lib_vhost { 'www.lib-ssl':
    servername                    => "${prefix}${domain}",
    ssl                           => true,
    error_log_file                => 'error.log',
    vhost_root                    => $vhost_root,
    cosign                        => true,
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
        path     => "${vhost_root}/cgi/l/login",
      },
      {
        provider => 'directory',
        path     => "${vhost_root}/cgi/m/medsearch"
      }
    ],

    access_logs                   => [
      {
        file => 'access.log',
        format => 'combined'
      },
      {
        file => 'clickstream.log',
        format => 'usertrack'
      },
    ],

    custom_fragment               => $skynet_fragment,

    # TODO: hopefully these can all be removed
    rewrites                      => [
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
