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
  class { 'apache::mod::shib': }
  include apache::mod::xsendfile

  include nebula::profile::apache::authz_umichlib
  include nebula::profile::apache::cosign

  # should be moved elsewhere to include as virtual all that might be present on the puppet master
  @nebula::apache::ssl_keypair {
    [
      'apps.lib.umich.edu',
      'copyright.umich.edu',
      'datamart.lib.umich.edu',
      'deepblue.lib.umich.edu',
      'developingwritersbook.com',
      'digital.bentley.umich.edu',
      'fulcrum.org',
      'open.umich.edu',
      'michiganelt.org',
      'mirlyn.lib.umich.edu',
      'staff.lib.umich.edu',
      'search.lib.umich.edu',
      'www.digitalculture.org',
      'www.lib.umich.edu',
      'www.mportfolio.umich.edu',
      'www.press.umich.edu',
      'www.publishing.umich.edu',
      'www.theater-historiography.org',
    ]:
  }

  # depends on ssl_keypairs above
  include nebula::profile::www_lib::vhosts::redirects

  $vhost_prefix = 'nebula::profile::www_lib::vhosts'

  ['default','www_lib','apps_lib','staff_lib','datamart','deepblue', 'openmich', 'mgetit', 'mportfolio', 'press', 'search'].each |$vhost| {
    class { "nebula::profile::www_lib::vhosts::${vhost}":
      prefix => $prefix,
      domain => $domain,
    }
  }


  include nebula::profile::www_lib::vhosts::fulcrum
  include nebula::profile::www_lib::vhosts::midaily
  include nebula::profile::www_lib::vhosts::publishing
  include nebula::profile::www_lib::vhosts::med

  nebula::apache::mirlyn_vhost { 'mirlyn':
    domain  => 'lib.umich.edu',
    app_url => 'http://app-mirlyn-api-production:30730/',
  }
  nebula::apache::mirlyn_vhost { 'm.mirlyn':
    domain  => 'lib.umich.edu',
    app_url => 'http://app-mirlyn-api-production:30730/',
    prefix  => 'm.',
  }
}
