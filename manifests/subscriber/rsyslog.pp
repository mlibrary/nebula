# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::subscriber::rsyslog {
  ensure_resource('service', 'rsyslog', { 'hasrestart' => true })
}
