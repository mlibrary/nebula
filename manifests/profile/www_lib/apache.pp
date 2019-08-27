# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::www_lib::apache
#
# Install apache for www_lib applications
#
# @param $prefix Will be applied to the beginning of all servernames, e.g. 'dev.' or 'test.'
# @param $domain Will be used as the suffix of all servernames, e.g. '.some.other.domain'
# @param $default_access Default access rules to use for server documentroots.
#   Should be in the format as accepted by the 'require' parameter for
#   directories for apache::vhost, for example: $default_access = 'all granted'
#
# @example
#   include nebula::profile::www_lib::apache
class nebula::profile::www_lib::apache (
  String $prefix = '',
  String $domain = 'lib.umich.edu',
  Variant[Hash,String] $default_access = {
    enforce  => 'all',
    requires => [
      'not env badrobot',
      'not env loadbalancer',
      'all granted'
    ]
  }
) {

  ensure_packages(['bsd-mailx'])

  class { 'nebula::profile::apache':
    log_formats => {
      vhost_combined => '%v:%p %a %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\" %D',
      combined       => '%a %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\" %D',
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

  class { 'apache::mod::php':
    # we'll configure php 7.3 separately
    package_name => 'libapache2-mod-php5.6',
    extensions   => ['.php','.phtml'],
    php_version  => '5.6'
  }

  include apache::mod::proxy
  include apache::mod::proxy_fcgi
  include apache::mod::proxy_http
  include apache::mod::reqtimeout
  include apache::mod::setenvif
  # causes apparent conflicts with cosign; to be resolved later
  #  class { 'apache::mod::shib': }
  include apache::mod::xsendfile

  include nebula::profile::apache::authz_umichlib
  include nebula::profile::apache::cosign

  # should be moved elsewhere to include as virtual all that might be present on the puppet master
  @nebula::apache::ssl_keypair {
    [
      'www.lib.umich.edu',
      'www.mportfolio.umich.edu',
      'datamart.lib.umich.edu',
      'deepblue.lib.umich.edu',
      'www.theater-historiography.org'
    ]:
  }

  nebula::apache::redirect_vhost_https { 'theater-historiography.org':
    ssl_cn        => 'www.theater-historiography.org',
    serveraliases => [
      'www.theater-historiography.com',
      'theater-historiography.com',
      'www.theatre-historiography.com',
      'theatre-historiography.com',
      'www.theatre-historiography.org',
      'theatre-historiography.org',
    ],
  }

  $vhost_prefix = 'nebula::profile::www_lib::vhosts'

  ['default','www_lib','datamart','deepblue'].each |$vhost| {
    class { "nebula::profile::www_lib::vhosts::${vhost}":
      prefix => $prefix,
      domain => $domain,
    }
  }

  class { 'nebula::profile::www_lib::vhosts::mportfolio':
    prefix => $prefix,
    domain => 'umich.edu'
  }

}
