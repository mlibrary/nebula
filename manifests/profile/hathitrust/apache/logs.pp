
# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::apache::logs
#
# hathitrust.org logs virtual host
#
# @example
#   include nebula::profile::hathitrust::apache::logs
class nebula::profile::hathitrust::apache::logs {

  cron { 'purge apache error logs':
    command => '/usr/bin/find /var/log/apache2 -type f -name "error_log*" -mtime +14 -exec /bin/rm {} \; > /dev/null 2>&1 ',
    user    => 'root',
    minute  => '17',
    hour    => '1',
  }

  cron { 'compress apache error logs':
    command => '/usr/bin/find /var/log/apache2 -type f -name "error_log*" ! -name "*.gz" -mtime +0 -exec /usr/bin/pigz -9 {} \; > /dev/null 2>&1',
    user    => 'root',
    minute  => '18',
    hour    => '1',
  }

}
