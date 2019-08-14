# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

define nebula::apache::www_lib_vhost (
  String $servername,
  Array[String] $serveraliases = [],
  Boolean $ssl = false,
  Boolean $cosign = false,
  Optional[String] $cosign_service = regsubst($servername,'\.umich\.edu$',''),
  String $ssl_cn = $servername,
  String $docroot = "/www/www.lib/web",
  Array[Hash] $directories = [],
  Array[Hash] $cosign_public_access_off_dirs = [],
  Optional[Array] $rewrites = undef,
  Optional[Array] $aliases = undef,
  Optional[String] $error_log_file = undef,
  Optional[Array] $access_logs = undef,
  Optional[String] $custom_fragment = undef,
) {

  $ssl_cert = "/etc/ssl/certs/${ssl_cn}.crt"
  $ssl_key = "/etc/ssl/private/${ssl_cn}.key"

  if($ssl) {
    $port = 443
  } else {
    $port = 80
  }

  $default_access = {
    enforce  => 'all',
    requires => [
      'not env badrobot',
      'not env loadbalancer',
      'all granted'
    ]
  }

  if($cosign) {
    $default_cosign_locations = [
      {
        provider        => 'location',
        path            => '/cosign/valid',
        sethandler      => 'cosign',
        require         => 'all granted',
        satisfy         => 'any',
        custom_fragment => @(EOT),
          Satisfy any
          CosignProtected Off
        |EOT
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
      CosignService		${cosign_service}
      CosignCrypto            ${ssl_key} ${ssl_crt} /etc/ssl/certs
      CosignAllowPublicAccess on
    |EOT

    $cosign_public_access_off = @(EOT)
      AuthType cosign
      Require valid-user
      CosignAllowPublicAccess off
    |EOT

    concat::fragment { "${title}-cosign":
      target => "${title}.conf",
      order  => 59,
      content => $cosign_fragment
    }

    $cosign_locations = $default_cosign_locations + $cosign_public_access_off_dirs.map |$dir| {
      $dir.merge( {
        custom_fragment => $cosign_public_access_off,
        require         => []
      })
    }
  } else {
    $cosign_locations = []
  }

  if($ssl) {
    realize Nebula::Apache::Ssl_keypair[$ssl_cn]
  }

  $default_directories = [
    {
      provider       => 'directory',
      path           => $docroot,
      options        => ['IncludesNOEXEC','Indexes','FollowSymLinks','MultiViews'],
      allow_override => ['AuthConfig','FileInfo','Limit','Options'],
      require        => $default_access
    },
    {
      provider       => 'directory',
      path           => '/',
      allow_override => ['None'],
      options        => ['FollowSymLinks'],
      require        => 'all denied'
    },
    {
      provider       => 'directory',
      path           => '/www/www.lib/cgi',
      allow_override => ['None'],
      options        => ['None'],
      require        => $default_access
    }
  ]

  apache::vhost { $title:
    docroot         => $docroot,
    manage_docroot  => false,
    directories     => $default_directories + $directories + $cosign_locations,
    log_level       => 'warn',
    priority        => false, # don't prepend a numeric identifier to the vhost
    ssl             => $ssl,
    # unused if ssl is false
    ssl_protocol    => '+TLSv1.2',
    ssl_cipher      => 'ECDHE-RSA-AES256-GCM-SHA384',
    ssl_cert        => $ssl_cert,
    ssl_key         => $ssl_key,
    rewrites        => $rewrites,
    error_log_file  => $error_log_file,
    access_logs     => $access_logs,
    custom_fragment => $custom_fragment
  }
}
