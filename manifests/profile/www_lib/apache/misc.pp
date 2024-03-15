# Copyright (c) 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::www_lib::apache::misc
#
# Configure Apache for miscellaneous www_lib applications
#
# @param $prefix Will be applied to the beginning of all servernames, e.g. 'dev.' or 'test.'
# @param $domain Will be used as the suffix of all servernames, e.g. '.some.other.domain'
#
# @example
#   include nebula::profile::www_lib::apache::misc
class nebula::profile::www_lib::apache::misc (
  String $prefix = '',
  String $domain = 'lib.umich.edu',
) {
  include nebula::profile::apache::authz_umichlib
  include nebula::profile::apache::auth_openidc

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
      'datamart.lib.umich.edu',
      'deepblue.lib.umich.edu',
      'developingwritersbook.com',
      'digital.bentley.umich.edu',
      'heartofdarknessarchive.org',
      'open.umich.edu',
      'michiganelt.org',
      'med.lib.umich.edu',
      'staff.lib.umich.edu',
      'search.lib.umich.edu',
      'digitalculture.org',
      'www.lib.umich.edu',
      'www.press.umich.edu',
      'www.publishing.umich.edu',
      'www.theater-historiography.org',
    ]:
  }
  # depends on ssl_keypairs above (or delcared in includes like apache::fulcrum)
  include nebula::profile::www_lib::vhosts::redirects

  $vhost_prefix = 'nebula::profile::www_lib::vhosts'

  ['default','www_lib','apps_lib','staff_lib','datamart','deepblue', 'openmich', 'mgetit', 'press', 'search'].each |$vhost| {
    class { "nebula::profile::www_lib::vhosts::${vhost}":
      prefix => $prefix,
      domain => $domain,
    }
  }

  include nebula::profile::www_lib::vhosts::midaily
  include nebula::profile::www_lib::vhosts::publishing
  include nebula::profile::www_lib::vhosts::med
}

