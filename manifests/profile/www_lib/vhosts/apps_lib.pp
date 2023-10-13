
# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::www_lib::vhosts::apps_lib
#
# apps.lib.umich.edu virtual host
#
# @example
#   include nebula::profile::www_lib::vhosts::apps_lib
class nebula::profile::www_lib::vhosts::apps_lib (
  String $prefix,
  String $domain,
  String $ssl_cn = 'apps.lib.umich.edu',
  String $www_lib_root = '/www/www.lib',
  String $docroot = "${www_lib_root}/web"
) {

  $servername = "${prefix}apps.${domain}"

  ### client cert

  $certname = $trusted['certname'];
  $client_cert = "/etc/ssl/private/${certname}.pem";

  concat { $client_cert:
    ensure => 'present',
    mode   => '0600',
    owner  => 'root',
  }

  concat::fragment { 'client cert':
    target => $client_cert,
    source => "/etc/puppetlabs/puppet/ssl/certs/${certname}.pem",
    order  =>  1
  }

  concat::fragment { 'client key':
    target => $client_cert,
    source => "/etc/puppetlabs/puppet/ssl/private_keys/${certname}.pem",
    order  =>  2
  }

  nebula::apache::www_lib_vhost { 'apps.lib-http':
    servername => $servername,
    docroot    => $docroot,
    usertrack  => true,

    rewrites   => [
      {
        rewrite_rule => '^(.*)$ https://%{HTTP_HOST}$1 [L,R]'
      },
    ],
  }

  nebula::apache::www_lib_vhost { 'apps.lib-https':
    servername                    => $servername,
    ssl                           => true,
    usertrack                     => true,
    auth_openidc                  => true,
    auth_openidc_redirect_uri     => 'https://apps.lib.umich.edu/openid-connect/callback',
    docroot                       => $docroot,

    directories                   => [
      {
        provider        => 'directory',
        path            => $docroot,
        options         => ['IncludesNOEXEC','Indexes','FollowSymLinks','MultiViews'],
        allow_override  => ['AuthConfig','FileInfo','Limit','Options'],
        require         => $nebula::profile::www_lib::apache::default_access,
      },
      {
        provider        => 'directory',
        path            => "${www_lib_root}/cgi",
        allow_override  => ['None'],
        options         => ['None'],
        require         => $nebula::profile::www_lib::apache::default_access,
      },
      {
        provider       => 'directory',
        path           => "${docroot}/canvas",
        options        => ['IncludesNOEXEC','Indexes','FollowSymLinks','MultiViews'],
        allow_override => ['AuthConfig','FileInfo','Limit','Options'],
        require        => $nebula::profile::www_lib::apache::default_access,
        addhandlers    => [{
          extensions => ['.php'],
          # TODO: Extract version or socket path to params/hiera
          handler    => 'proxy:unix:/run/php/php8.1-fpm.sock|fcgi://localhost'
        }],
      },
      {
        # Deny access to raw php sources by default
        # To re-enable it's recommended to enable access to the files
        # only in specific virtual host or directory
        provider => 'filesmatch',
        path     => '.+\.phps$',
        require  => 'all denied'
      },
      # Passive authn globally
      {
        provider        => 'location',
        path            => "/",
        auth_type       => 'openid-connect',
        require         => 'valid-user',
        custom_fragment => 'OIDCUnAuthAction pass'
      },
      # Force authn for these paths
      {
        provider        => 'location',
        path            => "/login",
        auth_type       => 'openid-connect',
        require         => 'valid-user',
        custom_fragment => 'OIDCUnAuthAction auth true'
      },
      {
        provider        => 'location',
        path            => '/pk',
        auth_type       => 'openid-connect',
        require         => 'valid-user',
        custom_fragment => 'OIDCUnAuthAction auth true'
      },
      {
        provider        => 'location',
        path            => '/vf/vflogin_dbsess.php',
        auth_type       => 'openid-connect',
        require         => 'valid-user',
        custom_fragment => 'OIDCUnAuthAction auth true'
      },
      {
        provider        => 'directory',
        path            => "${www_lib_root}/cgi/l/login",
        auth_type       => 'openid-connect',
        require         => 'valid-user',
        custom_fragment => 'OIDCUnAuthAction auth true'
      },
      {
        provider        => 'locationmatch',
        path            => '^/instruction/request',
        custom_fragment => @(EOT)
          # Set remote user header to allow app to use http header auth.
          RequestHeader set X-Remote-User     "expr=%{REMOTE_USER}"
          RequestHeader set X-Authzd-Coll     %{AUTHZD_COLL}e
          RequestHeader set X-Public-Coll     %{PUBLIC_COLL}e
          RequestHeader set X-Forwarded-Proto 'https'
          RequestHeader unset X-Forwarded-For
          Header set "Strict-Transport-Security" "max-age=3600"
        | EOT
      },
      # This must be declared after the above block or it will be superseded. 
      {
        provider        => 'location',
        path            => '/instruction/request/login',
        auth_type       => 'openid-connect',
        require         => 'valid-user',
        custom_fragment => 'OIDCUnAuthAction auth true'
      },
    ],

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
      {
        rewrite_cond => '%{REQUEST_URI} !^/openid-connect',
        rewrite_rule => '^(/instruction/request.*)$ https://sali1.lib.umich.edu:8443$1 [P]',
      },

      { rewrite_rule => '^/my-account/favorites - [last]' },
      { rewrite_rule => '^/user/.*/favorites - [last]' },
      { rewrite_rule => '^/my-account/checkouts                    https://account.lib.umich.edu/current-checkouts                    [redirect=permanent,last]' },
      { rewrite_rule => '^/my-account/history                      https://account.lib.umich.edu/past-activity/u-m-library            [redirect=permanent,last]' },
      { rewrite_rule => '^/my-account/notifications                https://account.lib.umich.edu/settings                             [redirect=permanent,last]' },
      { rewrite_rule => '^/my-account/holds-recalls                https://account.lib.umich.edu/pending-requests/u-m-library         [redirect=permanent,last]' },
      { rewrite_rule => '^/my-account/bookings                     https://account.lib.umich.edu/pending-requests/u-m-library         [redirect=permanent,last]' },
      { rewrite_rule => '^/my-account/fines                        https://account.lib.umich.edu/fines-and-fees                       [redirect=permanent,last]' },
      { rewrite_rule => '^/my-account/ill-transactions             https://account.lib.umich.edu/pending-requests/interlibrary-loan   [redirect=permanent,last]' },
      { rewrite_rule => '^/my-account/special-collections-requests https://account.lib.umich.edu/pending-requests/special-collections [redirect=permanent,last]' },
      { rewrite_rule => '^/my-account/profile                      https://account.lib.umich.edu/settings                             [redirect=permanent,last]' },
      { rewrite_rule => '^/my-account                              https://account.lib.umich.edu/                                     [redirect=permanent,last]' },
      { rewrite_rule => '^/user/.*/checkouts                       https://account.lib.umich.edu/current-checkouts                    [redirect=permanent,last]' },
      { rewrite_rule => '^/user/.*/history                         https://account.lib.umich.edu/past-activity/u-m-library            [redirect=permanent,last]' },
      { rewrite_rule => '^/user/.*/notifications                   https://account.lib.umich.edu/settings                             [redirect=permanent,last]' },
      { rewrite_rule => '^/user/.*/holds-recalls                   https://account.lib.umich.edu/pending-requests/u-m-library         [redirect=permanent,last]' },
      { rewrite_rule => '^/user/.*/bookings                        https://account.lib.umich.edu/pending-requests/u-m-library         [redirect=permanent,last]' },
      { rewrite_rule => '^/user/.*/fines                           https://account.lib.umich.edu/fines-and-fees                       [redirect=permanent,last]' },
      { rewrite_rule => '^/user/.*/ill-transactions                https://account.lib.umich.edu/pending-requests/interlibrary-loan   [redirect=permanent,last]' },
      { rewrite_rule => '^/user/.*/special-collections-requests    https://account.lib.umich.edu/pending-requests/special-collections [redirect=permanent,last]' },
      { rewrite_rule => '^/user/.*/profile                         https://account.lib.umich.edu/settings                             [redirect=permanent,last]' },
    ],

    aliases                       => [
      {
        scriptalias => '/cgi/',
        path        => "${www_lib_root}/cgi/",
      },
    ],

    ssl_proxyengine               => true,
    ssl_proxy_check_peer_name     => 'on',
    ssl_proxy_check_peer_expire   => 'on',
    ssl_proxy_machine_cert        => $client_cert,

    custom_fragment               => @(EOT)
      ProxyPassReverse / https://sali1.lib.umich.edu:8443/
    | EOT
  }
}
