# Copyright (c) 2019-2023 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::apache::auth_openidc
#
# Configures auth_openidc for apache
#
# @param oidc_metadata The OIDC provider metadata URL, for example:
#   "https://weblogin.lib.umich.edu/.well-known/openid-configuration"
#
# @param oidc_client_id The OIDC client ID, foir example
#   "darkblue"
#
# @param oidc_client_secret The value of the secret shared by the client and provider
#
# @param oidc_crypto The hash used to encrypt the local session cache
#   can be generated from "openssl rand -hex 128"
#
# @example
#   include nebula::profile::apache::auth_openidc

class nebula::profile::apache::auth_openidc (
  String $oidc_metadata,
  String $oidc_client_id,
  String $oidc_client_secret,
  String $oidc_crypto,
) {

  apache::mod { 'auth_openidc':
    package       => 'libapache2-mod-auth-openidc',
  }
  include apache::mod::authn_core
  include apache::mod::authz_user

  file { 'auth_openidc.conf':
    ensure  => file,
    path    => "${::apache::mod_dir}/auth_openidc.conf",
    mode    => '0700',
    content => template('nebula/profile/apache/auth_openidc.conf.erb'),
    require => Exec["mkdir ${::apache::mod_dir}"],
    before  => File[$::apache::mod_dir],
    notify  => Class['apache::service'],
  }

  file { '/var/cache/apache2/mod_auth_openidc':
    ensure => 'directory',
  }

  file { '/var/cache/apache2/mod_auth_openidc/oidc-sessions':
    ensure => 'directory',
    owner  => 'nobody',
    group  => 'nogroup',
    mode   => '0700'
  }

}
