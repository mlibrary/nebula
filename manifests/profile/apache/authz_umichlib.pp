# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::apache::authz_umichlib
#
# Configures authz_umichlib and oracle client for apache
#
# @param dbd_params The value to use for DBDParams, for example:
#   "user=somebody,pass=whatever,server=whatever"
#
# @example
#   include nebula::profile::apache::authz_umichlib

class nebula::profile::apache::authz_umichlib (
  String $dbd_params,
) {

  include apache::mod::dbd

  package { 'libaprutil1-dbd-oracle': }

  apache::mod { 'authz_umichlib':
    package       => 'libapache2-mod-authz-umichlib',
    loadfile_name => 'zz_authz_umichlib.load'
  }

  file { 'authz_umichlib.conf':
    ensure  => file,
    path    => "${::apache::mod_dir}/authz_umichlib.conf",
    mode    => $::apache::file_mode,
    content => template('nebula/profile/apache/authz_umichlib.conf.erb'),
    require => Exec["mkdir ${::apache::mod_dir}"],
    before  => File[$::apache::mod_dir],
    notify  => Class['apache::service'],
  }

  file_line { '/etc/apache2/envvars ORACLE_HOME':
    ensure => 'present',
    line   => "export ORACLE_HOME=/etc/oracle",
    match  => "/^export ORACLE_HOME=/",
    path   => '/etc/apache2/envvars'
  }

}
