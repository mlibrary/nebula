# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::subscriber::systemctl_daemon_reload {
  exec { 'systemctl daemon-reload':
    command     => '/bin/systemctl daemon-reload',
    refreshonly => true,
  }
}
