# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::hosts
#
# Manage /etc/hosts for HathiTrust applications
#
# @example
#   include nebula::profile::hathitrust::hosts
class nebula::profile::hathitrust::hosts(
  String $mysql_sdr,
  String $mysql_htdev,
  String $apps_ht,
  Array[String] $solr_search,
  String $solr_catalog,
  String $solr_vufind_primary,
  String $solr_vufind_failover
) {

  host { 'localhost':
    ip => '127.0.0.1'
  }

  host { $::hostname:
    host_aliases => [$::fqdn],
    ip           => $::ipaddress
  }

  host { 'ip6-localhost':
    host_aliases => ['localhost', 'ip6-loopback'],
    ip           => '::1'
  }

  host { 'ip6-allnodes':
    ip => 'ff02::1'
  }

  host { 'ip6-allrouters':
    ip => 'ff02::2'
  }

  host { 'mysql-sdr':
    comment => 'ht mysql sdr',
    ip      => $mysql_sdr
  }

  host { 'mysql-htdev':
    comment => 'ht mysql dev',
    ip      => $mysql_htdev
  }

  host { 'apps-ht':
    comment => 'ht app server',
    ip      => $apps_ht
  }

  $solr_search.each |Integer $i, String $ip| {
    host { "solr-sdr-search-${$i+1}":
      ip      => $ip
    }
  }

  host { 'solr-sdr-catalog':
    comment => 'solr (ht catalog)',
    ip      => $solr_catalog
  }

  host { 'solr-vufind':
    comment => 'solr (vufind primary)',
    ip      => $solr_vufind_primary
  }

  host { 'solr-vufind-failover':
    comment => 'solr (vufind failover)',
    ip      => $solr_vufind_failover
  }

}
