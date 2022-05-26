# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::logrotate
#
# Puppet should match Debian's logrotate defaults.
#
# @example
#   include nebula::profile::logrotate
class nebula::profile::logrotate {
  logrotate::rule {
    default:
      missingok    => true,
      rotate_every => 'week',
      create       => true,
      create_mode  => '0660',
      create_owner => 'root',
      create_group => 'utmp',
      rotate       => 4,
      ;
# Override the logrotate module definition for 
# wtmp and btmp to apply our preferred 4 x weekly schedule 
    'wtmp':
      path        => '/var/log/wtmp',
      create_mode => '0664',
      ;
    'btmp':
      path        => '/var/log/btmp',
      ;
  }
}
