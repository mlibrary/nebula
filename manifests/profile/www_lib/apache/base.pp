# Copyright (c) 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::www_lib::apache::base
#
# The base setup for "www-lib" Apache hosts, here to allow for extraction
# and further refactoring.
#
class nebula::profile::www_lib::apache::base {
  include nebula::profile::logrotate

  ensure_packages(['bsd-mailx'])

  class { 'nebula::profile::apache':
    log_formats => {
      vhost_combined => '%v:%p %a %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\" %D \"%{skynet}C\"',
      combined       => '%a %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\" %D \"%{skynet}C\"',
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

  class { 'apache::mod::proxy':
    proxy_timeout => '300',
  }

  include apache::mod::proxy_fcgi
  include apache::mod::proxy_http
  include apache::mod::reqtimeout
  include apache::mod::setenvif
  class { 'apache::mod::shib': }
  include apache::mod::xsendfile

  class { 'nebula::profile::shibboleth':
    config_source    => 'puppet:///shibboleth-www_lib',
    watchdog_minutes => '*/30',
  }

  file { '/etc/apache2/mods-available/shib2.conf':
    ensure  => 'present',
    content => template('nebula/profile/www_lib/shib2.conf.erb'),
    require => File['/etc/apache2/mods-available'],
  }

  file { '/etc/apache2/mods-enabled/shib2.conf':
    ensure  => 'link',
    target  => '/etc/apache2/mods-available/shib2.conf',
    require => File['/etc/apache2/mods-available/shib2.conf'],
  }

}
