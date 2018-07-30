# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Reload systemd's daemon
#
# @example
class nebula::systemd::daemon_reload {
  exec { '/usr/bin/systemctl daemon-reload':
    refreshonly => true,
  }
}
