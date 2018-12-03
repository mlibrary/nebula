
# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::apache::statistics
#
# hathitrust.org statistics virtual host
#
# @example
#   include nebula::profile::hathitrust::apache::statistics
class nebula::profile::hathitrust::apache::statistics {

  cron { 'callnumber prefix counts':
    command => "SDRROOT=/htapps/www perl /htapps/www/sites/www.hathitrust.org/modules/custom/callnumber_prefix_counts.pl > /htapps/www/sites/www.hathitrust.org/cron_reporting.0 2>&1 || /usr/bin/mail -s 'Callnumber prefix Cronjob failed' eliotwsc@umich.edu",
    user    => 'libadm',
    minute  => '0',
    hour    => '3',
  }

  cron { 'pd callnumber prefix counts':
    command => "SDRROOT=/htapps/www perl /htapps/www/sites/www.hathitrust.org/modules/custom/PD_callnumber_prefix_counts.pl > /htapps/www/sites/www.hathitrust.org/cron_reporting.1 2>&1 || /usr/bin/mail -s 'PD Callnumber prefix Cronjob failed' eliotwsc@umich.edu",
    user    => 'libadm',
    minute  => '10',
    hour    => '3',
  }

  cron { 'pd callnumber statistics':
    command => "SDRROOT=/htapps/www perl /htapps/www/sites/www.hathitrust.org/extra_perl/Solr/PD_stats.pl > /htapps/www/sites/www.hathitrust.org/cron_reporting.2 2>&1 || /usr/bin/mail -s 'PD Callnumber Statistics Cronjob failed' eliotwsc@umich.edu",
    user    => 'libadm',
    minute  => '50',
    hour    => '3',
  }

  cron { 'rss create statistics':
    command => "SDRROOT=/htapps/www /usr/bin/php /htapps/www/sites/www.hathitrust.org/modules/custom/RSSGenerateStatisticsFile.php > /htapps/www/sites/www.hathitrust.org/cron_reporting.3 2>&1 || /usr/usr/bin/mail -s 'RSS Create Cronjob failed' eliotwsc@umich.edu",
    user    => 'libadm',
    minute  => '0',
    hour    => '3',
    weekday => '1'
  }

  cron { 'callnumber statistics':
    command => "SDRROOT=/htapps/www perl /htapps/www/sites/www.hathitrust.org/extra_perl/Solr/stats.pl > /htapps/www/sites/www.hathitrust.org/cron_reporting.4 2>&1 || /usr/bin/mail -s 'Callnumber Statistics Cronjob failed' eliotwsc@umich.edu",
    user    => 'libadm',
    minute  => '0',
    hour    => '4',
  }

  cron { 'rss create':
    command => "SDRROOT=/htapps/www /usr/bin/php /htapps/www/sites/www.hathitrust.org/modules/custom/RSScreate.php > /htapps/www/sites/www.hathitrust.org/cron_reporting.5 2>&1 || /usr/bin/mail -s 'RSS Create Cronjob failed' eliotwsc@umich.edu",
    user    => 'libadm',
    minute  => '0',
    hour    => '4',
    weekday => '1'
  }

  cron { 'get pod volumes':
    command  => "SDRROOT=/htapps/www perl /htapps/www/sites/www.hathitrust.org/extra_perl/get_pod_volumes.pl > /htapps/www/sites/www.hathitrust.org/cron_reporting.6 2>&1 || /usr/bin/mail -s 'Get POD Volumes Cronjob failed' eliotwsc@umich.edu",
    user     => 'libadm',
    minute   => '0',
    hour     => '0',
    monthday => '1'
  }

  cron { 'hourly reporting':
    command => "SDRROOT=/htapps/www /usr/bin/php /htapps/www/command-line-cron.php > /htapps/www/sites/www.hathitrust.org/cron_reporting.7 2>&1 || /usr/bin/mail -s 'Once-an-hour Cronjob failed' eliotwsc@umich.edu",
    user    => 'libadm',
    minute  => '0',
  }



}
