# Copyright (c) 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::fulcrum::logrotate {
  include nebula::profile::logrotate

  logrotate::rule { 'fulcrum':
    path          => '/fulcrum/app/shared/log/*.log',
    rotate        => 7,
    rotate_every  => 'day',
    missingok     => true,
    compress      => true,
    ifempty       => false,
    delaycompress => true,
    copytruncate  => true,
    su            => true,
    su_user       => 'fulcrum',
    su_group      => 'fulcrum',
  }
}
