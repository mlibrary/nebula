# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Declaration of a service to be made available via reverse proxy. This
# should be exported by an app and then collected by the web server role or
# profile.

# There are many keys in hiera for each instance, including some new ones
# for this profile:
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
#
# The defaults are applied at the named_instance class, not here.

define nebula::proxied_app(
  String  $public_hostname,
  String  $url_root,
  String  $protocol,          # protocol to the app, not of the vhost
  String  $hostname,
  Integer $port,
  Boolean $ssl,
  String  $ssl_crt,
  String  $ssl_key,
  String  $static_path,
  Optional[String]  $sendfile_path,     # If set, XSendFile will be enabled here
){
  # These are straightforward translations to maintain parity with the
  # ansible template. All of these names and semantics should be revisited
  # and likely decomposed into resources/fragments that can be assembled
  # by the web host after being exported or virtualized wherever needed.
  $apache_app_hostname  = $hostname
  $apache_app_name      = $title
  $apache_cosign_factor = 'UMICH.EDU'
  $apache_domain        = $public_hostname
  $apache_port          = $port
  $apache_terminate_ssl = $ssl
  $apache_ssl_crt       = $ssl_crt
  $apache_ssl_key       = $ssl_key
  $apache_static_path   = $static_path
  $apache_url_root      = $url_root

  # TODO: Get these flags from instance config
  $apache_cosign_deny_friend = false
  $apache_static_directories = true
  $apache_use_cosign         = true

  # TODO: Determine the current needs for aliases/whitelisting and
  # decide the best way to manage them. These are stubbed for now.
  $apache_aliases = []
  $apache_whitelisted_ips = []

  # Not yet for actual management/distribution; verification pending
  file { "/sysadmin/archive/app-proxies/${title}.conf":
    ensure  => 'present',
    content => template('nebula/apache/proxy_vhost.erb'),
  }
}
