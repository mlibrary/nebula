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
      vhost_combined => '%v:%p %a %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\" %D',
      combined       => '%a %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\" %D'
    }
  }

  include nebula::profile::apache::monitoring

  class { 'nebula::profile::monitor_pl':
    directory     => $nebula::profile::apache::monitoring::monitor_dir,
    shibboleth    => false,
    solr_cores    => lookup('nebula::www_lib::monitor::solr_cores'),
    http_checks   => lookup('nebula::www_lib::monitor::http_checks',
    default_value => []),
    mysql         => lookup('nebula::www_lib::monitor::mysql')
  }

  apache::mod { ['access_compat','asis','authz_groupfile']: }
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
    proxy_timeout => 300,
  }

  include apache::mod::proxy_fcgi
  include apache::mod::proxy_http
  include apache::mod::reqtimeout
  include apache::mod::setenvif
  include apache::mod::xsendfile
}
