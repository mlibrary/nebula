# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::role::app_host::prod_with_search_metrics {
  include nebula::role::app_host::prod
  include nebula::profile::client_cert_https
  # solr_monitor can't work without solr Profile
  #include nebula::profile::search::catalog::solr_monitor
}
