# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

define nebula::apache::www_lib_vhost (
  String $servername,
  Variant[Boolean, String] $docroot,
  Array[String] $serveraliases = [],
  Boolean $ssl = false,
  Optional[Integer] $port_override = undef,
  Boolean $cosign = false,
  Boolean $usertrack = false,
  Optional[String] $cosign_service = regsubst($servername,'\.umich\.edu$',''),
  String $ssl_cn = $servername,
  Array[Hash] $directories = [],
  Array[Hash] $cosign_public_access_off_dirs = [],
  Optional[Array] $rewrites = undef,
  Optional[Array] $aliases = undef,
  String $logging_prefix = '',
  String $custom_fragment = '',
  Optional[String] $redirect_source = undef,
  Optional[String] $redirect_status = undef,
  Optional[String] $redirect_dest = undef,
  Optional[String] $redirectmatch_regexp = undef,
  Optional[String] $redirectmatch_status = undef,
  Optional[String] $redirectmatch_dest = undef,
  Optional[Array] $request_headers = undef,
  Optional[Array] $headers = undef,
  Boolean $ssl_proxyengine = false,
  Optional[String] $ssl_proxy_check_peer_name = undef,
  Optional[String] $ssl_proxy_check_peer_expire = undef,
  Optional[Array] $setenv = undef,
  Optional[Array] $setenvifnocase = undef,
  $priority = false
) {
  $ssl_cert = "${nebula::profile::apache::ssl_cert_dir}/${ssl_cn}.crt"
  $ssl_key = "${nebula::profile::apache::ssl_key_dir}/${ssl_cn}.key"

  # @param port_override is used if you want to set the port differently
  # such as using port 443 even with ssl set to false during a proxy.
  if $port_override {
    $port = $port_override
  } else {
    if($ssl) {
      $port = 443
    } else {
      $port = 80
    }
  }

  if($usertrack) {
    $usertrack_fragment = @(EOT)
      CookieTracking on
      CookieDomain .lib.umich.edu
      CookieName skynet
    |EOT
    $usertrack_log = [
      {
        file   => "${logging_prefix}clickstream.log",
        format => 'usertrack'
      },
    ]
  } else {
    $usertrack_fragment = ''
    $usertrack_log = []
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
      },
    ]

    $cosign_fragment = @("EOT")
      CosignProtected  On
      CosignHostname   weblogin.umich.edu
      CosignValidReference              ^https?:\/\/[^/]+.umich\.edu(\/.*)?
      CosignValidationErrorRedirect      http://weblogin.umich.edu/cosign/validation_error.html
      CosignCheckIP    never
      CosignRedirect   https://weblogin.umich.edu/
      CosignNoAppendRedirectPort  On
      CosignPostErrorRedirect  https://weblogin.umich.edu/post_error.html
      CosignService    ${cosign_service}
      CosignCrypto     ${ssl_key} ${ssl_cert} ${nebula::profile::apache::ssl_cert_dir}
      CosignAllowPublicAccess on
    |EOT

    $cosign_public_access_off = @(EOT)
      AuthType cosign
      Require valid-user
      CosignAllowPublicAccess off
    |EOT

    concat::fragment { "${title}-cosign":
      target  => "${title}.conf",
      order   => 59,
      content => $cosign_fragment,
    }

    $cosign_locations = $default_cosign_locations + $cosign_public_access_off_dirs.map |$dir| {
      $dir.merge( {
        custom_fragment => $cosign_public_access_off,
        require         => [],
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
      path           => '/',
      allow_override => ['None'],
      options        => ['FollowSymLinks'],
      require        => 'all denied'
    },
  ]

  apache::vhost { $title:
    servername                  => $servername,
    port                        => $port,
    docroot                     => $docroot,
    manage_docroot              => false,
    directories                 => $default_directories + $directories + $cosign_locations,
    log_level                   => 'warn',
    priority                    => $priority,
    ssl                         => $ssl,
    # unused if ssl is false
    ssl_protocol                => '+TLSv1.2',
    ssl_cipher                  => 'ECDHE-RSA-AES256-GCM-SHA384',
    ssl_cert                    => $ssl_cert,
    ssl_key                     => $ssl_key,
    rewrites                    => $rewrites,
    error_log_file              => "${logging_prefix}error.log",
    access_logs                 => [
      {
        file   => "${logging_prefix}access.log",
        format => 'combined'
      },
    ] + $usertrack_log,
    custom_fragment             => @("EOT"),
      ${custom_fragment}
      ${usertrack_fragment}
    | EOT
    redirect_source             => $redirect_source,
    redirect_status             => $redirect_status,
    redirect_dest               => $redirect_dest,
    redirectmatch_regexp        => $redirectmatch_regexp,
    redirectmatch_status        => $redirectmatch_status,
    redirectmatch_dest          => $redirectmatch_dest,
    request_headers             => $request_headers,
    headers                     => $headers,
    serveraliases               => $serveraliases,
    aliases                     => $aliases,
    ssl_proxyengine             => $ssl_proxyengine,
    ssl_proxy_check_peer_name   => $ssl_proxy_check_peer_name,
    ssl_proxy_check_peer_expire => $ssl_proxy_check_peer_expire,
    setenvifnocase              => $setenvifnocase,
    setenv                      => $setenv,
  }
}
