# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::prometheus::exporter::webserver::quod {
  class { "nebula::profile::prometheus::exporter::webserver::base":
    target => "quod"
  }
}
