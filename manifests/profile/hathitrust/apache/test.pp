
# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::apache::test
#
# hathitrust.org test virtual host
#
# @example
#   include nebula::profile::hathitrust::apache::test
class nebula::profile::hathitrust::apache::test {

  cron { 'purge apache access logs':
    command => "/usr/bin/find /var/log/apache2 -regextype posix-egrep -type f -mtime +14 -regex '.*/(access|error)_log.*-.*' -exec /bin/rm {} \; > /dev/null 2>&1"
',
    user    => 'root',
    minute  => '7',
    hour    => '1',
    monthday => '*'
  }

}
