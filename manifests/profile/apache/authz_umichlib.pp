# Copyright (c) 2019-2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::apache::authz_umichlib
#
# Configures authz_umichlib and oracle client for apache
#
# @param dbd_params The value to use for DBDParams, for example:
#   "user=somebody,pass=whatever,server=whatever"
#
# @param oracle_home The value for the $ORACLE_HOME environment variable.
#
# @param oracle_servers The names of servers (Hash) and their relevant 
#   aliases (String Array). Note servers should be lowercase while aliases
#   must be uppercase.
#
#   e.g. 
#     myserver:
#       - ORCL.MYSERVER1
#       - ORCL.MYSERVER2 
#
# @param oracle_sid The SID for the oracle service. Oracle default is 
#   set as default here
#
# @param oracle_port The port for the oracle service. Oracle default is 
#   set as default here
#
# @example
#   include nebula::profile::apache::authz_umichlib

class nebula::profile::apache::authz_umichlib (
  String $dbd_params,
  Hash[String, Array[String]] $oracle_servers,
  String $oracle_home,
  String $oracle_sid = 'orcl',
  Integer $oracle_port = 1521,
  String $exempt_paths = '/www/www.lib/cgi /www/staff.lib/web/coral /www/staff.lib/web/linkscan /www/staff.lib/web/linkscan117 /www/staff.lib/web/pagerate /www/staff.lib/web/ptf /www/staff.lib/web/ts /www/staff.lib/web/sites/staff.lib.umich.edu/local /www/staff.lib/web/funds_transfer /www/staff.lib/web/sites/staff.lib.umich.edu.funds_transfer /tb/www.lib/instruction-request /instruction/request',
) {

  include apache::mod::dbd

  # Note: Packages for modules must be declared in the mod stanzas and
  # not in ensure_packages.
  ensure_packages (
    [
      'libdbd-oracle-perl',
      'libaprutil1-dbd-oracle',
      'oracle-instantclient12.1-basic',
      'oracle-instantclient12.1-devel',
    ]
  )

  file { '/etc/ld.so.conf.d/oracle-instantclient.conf':
    content => "/usr/lib/oracle/12.1/client64/lib\n",
    notify  => Exec['oracle driver ldconfig'],
  }

  exec { 'oracle driver ldconfig':
    refreshonly => true,
    command     => '/sbin/ldconfig',
  }

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
    ensure  => 'present',
    line    => "export ORACLE_HOME=${oracle_home}",
    match   => '/^export ORACLE_HOME=/',
    path    => '/etc/apache2/envvars',
    require => Class['apache']
  }

  # This is the default instant client directory for the *.ora files.
  file {
    [
      $oracle_home,
      "${oracle_home}/network/",
      "${oracle_home}/network/admin",
    ]:
    ensure => 'directory',
  }

  file { 'sqlnet.ora':
    ensure  => 'file',
    path    => "${oracle_home}/network/admin/sqlnet.ora",
    content => template('nebula/profile/apache/sqlnet.ora.erb'),
    notify  => Class['apache::service'],
  }

  file { 'tnsnames.ora':
    ensure  => 'file',
    path    => "${oracle_home}/network/admin/tnsnames.ora",
    content => template('nebula/profile/apache/tnsnames.ora.erb'),
    notify  => Class['apache::service'],
  }
}
