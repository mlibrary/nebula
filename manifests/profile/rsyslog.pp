# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# we don't create or manage this, but puppet needs to know about it in
# order to notify it
class nebula::profile::rsyslog {
  ensure_resource('service', 'rsyslog', { 'hasrestart' => true })
}
