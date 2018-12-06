# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::ingest_hosts
#
# Manage /etc/hosts for HathiTrust ingest servers
#
# @example
#   include nebula::profile::hathitrust::ingest_hosts
class nebula::profile::hathitrust::ingest_hosts(
  String $mysql_sdr,
  String $mysql_quod,
  Array[String] $solr_build,
  Array[String] $solr_build_new,
  Array[String] $solr_search,
  String $solr_dev,
  String $solr_catalog,
  String $solr_vufind_primary,
  String $solr_vufind_failover
) {

  host { $::hostname:
    host_aliases => [$::fqdn],
    ip           => $::ipaddress
  }

  host { 'mysql-sdr':
    comment => 'ht mysql sdr',
    ip      => $mysql_sdr
  }

  host { 'mysql-quod':
    ip => $mysql_quod
  }

  $solr_build.each |Integer $i, String $ip| {
    host { "solr-sdr-build-${$i+1}":
      ip => $ip
    }
  }

  $solr_build_new.each |Integer $i, String $ip| {
    host { "solr-sdr-build-new-${$i+1}":
      ip => $ip
    }
  }

  $solr_search.each |Integer $i, String $ip| {
    host { "solr-sdr-search-${$i+1}":
      ip => $ip
    }
  }

  host { 'solr-sdr-dev':
    ip => $solr_dev
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
