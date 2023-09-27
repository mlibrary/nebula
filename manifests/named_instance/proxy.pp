# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Declaration of a service to be made available via reverse proxy. This
# should be exported by a named instance and then collected by the web server role or
# profile.

# There are many keys in hiera for each instance, including some new ones
# for this resource type:
#   public_hostname: hostname users access
#   url_root: root url segment/suffix on the public hostname; defaults to /
#   protocol: which protocol the app serves; defaults to http
#   hostname: the hostname for the app as reachable by the web server; defaults to app-<title>
#   port: port the app listens on
#   ssl: boolean of whether to use SSL or not; defaults to true
#   ssl_crt: the name (not full path) of the SSL certificate file;
#            defaults to <public_hostname>.crt
#   ssl_key: the name (not full path) of the SSL key file;
#            defaults to <public_hostname>.key
#   sendfile_path: if set, make this path available for X-Sendfile
#   whitelisted_ips: if set, only allow access from this array of IPs; otherwise nobaddies
#   public_aliases: add a ServerAlias for each hostname listed here (for multihomed vhost dispatch)
#
# Meaningful defaults are applied at the named_instance class, not here.

define nebula::named_instance::proxy(
  String  $public_hostname,
  String  $url_root,
  Integer $port,
  String  $path,
  String  $protocol = 'http',          # protocol to the app, not of the vhost
  String  $hostname = "app-${title}",
  Boolean $ssl = true,
  String  $ssl_crt = "${public_hostname}.crt",
  String  $ssl_key = "${public_hostname}.key",
  String  $static_path = "${path}/current/public",
  Boolean $static_directories = false,
  Optional[String] $sendfile_path = undef,     # If set, XSendFile will be enabled here
  Array[String]    $public_aliases = [],
  Array[String]    $whitelisted_ips = [],
){
  # These are straightforward translations to maintain parity with the
  # ansible template. All of these names and semantics should be revisited
  # and likely decomposed into resources/fragments that can be assembled
  # by the web host after being exported or virtualized wherever needed.
  $apache_app_hostname       = $hostname
  $apache_app_name           = $title
  $apache_domain             = $public_hostname
  $apache_port               = $port
  $apache_terminate_ssl      = $ssl
  $apache_ssl_crt            = $ssl_crt
  $apache_ssl_key            = $ssl_key
  $apache_static_path        = $static_path
  $apache_static_directories = $static_directories
  $apache_url_root           = $url_root
  $apache_aliases            = $public_aliases
  $apache_whitelisted_ips    = $whitelisted_ips

  # Not yet for actual management/distribution; verification pending
  file { "/sysadmin/archive/app-proxies/${title}.conf":
    ensure  => 'present',
    content => template('nebula/named_instance/proxy_vhost.erb'),
    require => File['/sysadmin/archive/app-proxies'],
  }

  ensure_resource('file', '/sysadmin/archive/app-proxies',
    {'ensure' => 'directory', 'require' => File['/sysadmin/archive']})

  ensure_resource('file', '/sysadmin/archive',
    {'ensure' => 'directory', 'require' => File['/sysadmin']})

  ensure_resource('file', '/sysadmin', {'ensure' => 'directory'})
}
