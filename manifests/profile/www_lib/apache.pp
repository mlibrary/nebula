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
  include nebula::profile::www_lib::apache_minimum

  include nebula::profile::apache::authz_umichlib
  include nebula::profile::apache::cosign

  class { 'apache::mod::php':
    # we'll configure php 7.3 separately
    package_name => 'libapache2-mod-php5.6',
    extensions   => ['.php','.phtml'],
    php_version  => '5.6'
  }

  # should be moved elsewhere to include as virtual all that might be present on the puppet master
  @nebula::apache::ssl_keypair {
    [
      'apps.lib.umich.edu',
      'apps.staff.lib.umich.edu',
      'copyright.umich.edu',
      'datamart.lib.umich.edu',
      'deepblue.lib.umich.edu',
      'developingwritersbook.com',
      'digital.bentley.umich.edu',
      'open.umich.edu',
      'michiganelt.org',
      'med.lib.umich.edu',
      'staff.lib.umich.edu',
      'search.lib.umich.edu',
      'www.digitalculture.org',
      'www.lib.umich.edu',
      'www.press.umich.edu',
      'www.publishing.umich.edu',
      'www.theater-historiography.org',
      'www.heartofdarknessarchive.com',
    ]:
  }
  # depends on ssl_keypairs above (or delcared in includes like fulcrum_apache)
  include nebula::profile::www_lib::vhosts::redirects

  $vhost_prefix = 'nebula::profile::www_lib::vhosts'

  ['default','www_lib','apps_lib','staff_lib','datamart','deepblue', 'openmich', 'mgetit', 'press', 'search'].each |$vhost| {
    class { "nebula::profile::www_lib::vhosts::${vhost}":
      prefix => $prefix,
      domain => $domain,
    }
  }

  include nebula::profile::www_lib::fulcrum_apache
  include nebula::profile::www_lib::vhosts::midaily
  include nebula::profile::www_lib::vhosts::publishing
  include nebula::profile::www_lib::vhosts::med
}
