# Copyright (c) 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Hosts file entries for Fulcrum backing services
class nebula::profile::fulcrum::hosts (
  $fedora = '127.0.0.1',
  $mysql = '127.0.0.1',
  $redis = '127.0.0.1',
  $solr = '127.0.0.1',
) {
  host { 'fedora':
    ip => $fedora,
  }

  host { 'mysql':
    ip => $mysql,
  }

  host { 'redis':
    ip => $redis,
  }

  host { 'solr':
    ip => $solr,
  }
}
