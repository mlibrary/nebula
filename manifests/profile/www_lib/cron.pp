# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::www_lib::cron (
  String $user = 'default_invalid',
  String $mailto = 'crons@default.invalid',
  Hash $extra_jobs = {},
) {
  include nebula::virtual::users
  realize User[$user]

  $extra_jobs.each |String $cron_title, Hash $cron_resource| {
    cron { $cron_title:
      * => $cron_resource,
    }
  }

  cron {
    default:
      user        => $user,
      environment => ["MAILTO=${mailto}"],
    ;

    'staff.lib parse':
      hour    => 3,
      minute  => 30,
      command => "/usr/bin/perl /www/staff.lib/web/sites/staff.lib.umich.edu/local/dashboard/parse.pl > /www/staff.lib/web/sites/staff.lib.umich.edu/local/dashboard/logs/${::hostname}-parse.log 2>&1",
    ;

    'Proactively scan the log files for suspcious activity':
      hour    => [0, 3, 6, 9, 12, 15, 18, 21],
      minute  => 52,
      command => '/www/www.lib/cron/bin/ezproxy-log-scan.sh > /dev/null 2>&1',
    ;
  }

  cron {
    default:
      user => 'root',
    ;

    'purge cosign tickets':
      hour    => 0,
      minute  => 7,
      command => '/usr/bin/find /var/cosign/filter -type f -mtime +1 -exec /bin/rm {} \; > /dev/null 2>&1',
    ;

    'purge apache access logs 1/2':
      hour    => 1,
      minute  => 7,
      command => '/usr/bin/find /var/log/apache2 -type f -mtime +14 -name "*log*" -exec /bin/rm {} \; > /dev/null 2>&1',
    ;

    'purge apache access logs 2/2':
      hour    => 1,
      minute  => 17,
      command => '/usr/bin/find /var/log/apache2 -type f -mtime +2  -name "*log*" ! -name "*log*gz" -exec /usr/bin/pigz {} \; > /dev/null 2>&1',
      require => Package['pigz'],
    ;

    'reload fcgi for Press site nightly':
      weekday => '1-6',
      hour    => 0,
      minute  => 4,
      command => '/bin/systemctl restart press',
    ;
  }

  ensure_packages(['pigz'])
}
