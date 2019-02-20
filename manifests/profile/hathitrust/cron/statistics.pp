
# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::cron::statistics
#
# hathitrust.org statistics cron jobs
#
# @example
#   include nebula::profile::hathitrust::cron::statistics
class nebula::profile::hathitrust::cron::statistics (
  String $mail_recipient,
  String $user = 'libadm',
  String $sdr_root = '/htapps/www'
){

  $drupal_home = "${sdr_root}/sites/www.hathitrust.org"

  cron {
    default:
      user        => $user,
      environment => ["MAILTO=${mail_recipient}","SDRROOT=${sdr_root}"];

    'callnumber prefix counts':
      command => "/usr/bin/perl ${drupal_home}/modules/custom/callnumber_prefix_counts.pl > ${drupal_home}/cron_reporting.0 2>&1 || /usr/bin/mail -s 'Callnumber prefix Cronjob failed' ${mail_recipient}",
      minute  => '0',
      hour    => '3';

    'pd callnumber prefix counts':
      command => "/usr/bin/perl ${drupal_home}/modules/custom/PD_callnumber_prefix_counts.pl > ${drupal_home}/cron_reporting.1 2>&1 || /usr/bin/mail -s 'PD Callnumber prefix Cronjob failed' ${mail_recipient}",
      minute  => '10',
      hour    => '3';

    'pd callnumber statistics':
      command => "/usr/bin/perl ${drupal_home}/extra_perl/Solr/PD_stats.pl > ${drupal_home}/cron_reporting.2 2>&1 || /usr/bin/mail -s 'PD Callnumber Statistics Cronjob failed' ${mail_recipient}",
      minute  => '50',
      hour    => '3';

    'rss create statistics':
      command => "/usr/bin/php ${drupal_home}/modules/custom/RSSGenerateStatisticsFile.php > ${drupal_home}/cron_reporting.3 2>&1 || /usr/usr/bin/mail -s 'RSS Create Cronjob failed' ${mail_recipient}",
      minute  => '0',
      hour    => '3',
      weekday => '1';

    'callnumber statistics':
      command => "/usr/bin/perl ${drupal_home}/extra_perl/Solr/stats.pl > ${drupal_home}/cron_reporting.4 2>&1 || /usr/bin/mail -s 'Callnumber Statistics Cronjob failed' ${mail_recipient}",
      minute  => '0',
      hour    => '4';

    'rss create':
      command => "/usr/bin/php ${drupal_home}/modules/custom/RSScreate.php > ${drupal_home}/cron_reporting.5 2>&1 || /usr/bin/mail -s 'RSS Create Cronjob failed' ${mail_recipient}",
      minute  => '0',
      hour    => '4',
      weekday => '1';

    'get pod volumes':
      command  => "/usr/bin/perl ${drupal_home}/extra_perl/get_pod_volumes.pl > ${drupal_home}/cron_reporting.6 2>&1 || /usr/bin/mail -s 'Get POD Volumes Cronjob failed' ${mail_recipient}",
      minute   => '0',
      hour     => '0',
      monthday => '1';

    'hourly reporting':
      command => "/usr/bin/php ${sdr_root}/command-line-cron.php > ${drupal_home}/cron_reporting.7 2>&1 || /usr/bin/mail -s 'Once-an-hour Cronjob failed' ${mail_recipient}",
      user    => 'libadm',
      minute  => '0';

  }
}
