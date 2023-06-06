# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

define nebula::apache::www_lib_vhost (
  String $servername,
  Variant[Boolean, String] $docroot,
  Array[String] $serveraliases = [],
  Boolean $ssl = false,
  Optional[Integer] $port_override = undef,
  Boolean $auth_openidc = false,
  Boolean $usertrack = false,
  Optional[String] $auth_openidc_redirect_uri = undef,
  String $ssl_cn = $servername,
  Array[Hash] $directories = [],
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
  Optional[String] $ssl_proxy_machine_cert = undef,
  Optional[Array] $setenv = undef,
  Optional[Array] $setenvifnocase = undef,
  Optional[Array] $error_documents = undef,
  $priority = false,
  Array[String] $default_allow_override = ['None'],
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

  # The perl path parameter is required to make sure scripts are found.
  # So we make sure it is added whether the variable is set or not.
  if $setenv {
    $setenv_with_perl = $setenv + 'PERL_USE_UNSAFE_INC 1'
  } else {
    $setenv_with_perl = [ 'PERL_USE_UNSAFE_INC 1' ]
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

  if($auth_openidc) {
    $auth_openidc_fragment = @("EOT")
      OIDCRedirectURI ${auth_openidc_redirect_uri}
      # For www_lib, we are sure that Shibboleth is installed, and we must
      # disable its "compatibility mode" with valid-user, or mod_auth_openidc never
      # gets a chance at the request. The name of the option and its docs
      # imply the reverse, but we want Compat On.
      # https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPApacheConfig#NativeSPApacheConfig-Server/VirtualHostOptions
      ShibCompatValidUser On
    |EOT
  } else {
    $auth_openidc_fragment = ''
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
    directories                 => $default_directories + $directories,
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
      ${auth_openidc_fragment}
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
    ssl_proxy_machine_cert      => $ssl_proxy_machine_cert,
    setenvifnocase              => $setenvifnocase,
    setenv                      => $setenv_with_perl,
    error_documents             => $error_documents,
  }
}
