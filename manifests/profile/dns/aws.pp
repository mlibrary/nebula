# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::dns::aws
#
# Configure dhclient for AWS hosts to add our search domain to resolv.conf,
# also suppresses AWS/DHCP supplied search domain.
#
# @example
#   include nebula::profile::dns::aws
class nebula::profile::dns::aws {

  $searchpaths = lookup('nebula::resolv_conf::searchpath')
  $searchpath_str = join($searchpaths, ' ')

  exec { 'restart_networking':
    command     => '/bin/systemctl restart networking',
    refreshonly => true,
  }

  file_line {
    default:
      path   => '/etc/dhcp/dhclient.conf',
      notify => Exec['restart_networking'],
    ;
    'search_domain':
      line => "supersede domain-search \"${searchpath_str}\";",
    ;
    'domain_name':
      line => 'supersede domain-name "";',
  }
}
