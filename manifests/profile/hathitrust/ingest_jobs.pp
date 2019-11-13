# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::ingest_jobs
#
# Manage the ingest systemd service for hathitrust
#
# @example
#   include nebula::profile::hathitrust::ingest_jobs
class nebula::profile::hathitrust::ingest_jobs(
  String $config,
  String $feed_home,
  String $stats_home,
  Array[String] $dcu_recipients,
  String $crms_renewals_source,
  String $crms_renewals_dest,
  String $recipient,
  String $rights_db_config,
  String $rights_log = '/tmp/populate_rights.log'
) {

  package { 'heirloom-mailx': }

  $feed_perl = "/usr/bin/perl -I ${feed_home}/lib"
  $feed_jobs = "${feed_home}/bin/feed_jobs"
  $feed_daily = "${feed_jobs}/feed.daily"
  $feed_log  = "${feed_home}/var/log"
  $joined_dcu_recipients = $dcu_recipients.join(',')
  $base_env = [
    "MAILTO=${recipient}",
    "FEED_HOME=${feed_home}"
  ]


  cron {
    default:
      environment => $base_env + [ "HTFEED_CONFIG=${config}" ],
      user        => 'libadm';

    ## HOURLY  JOBS

    # Pickup rights from CRMS & aleph and populate the rights database
    'CRMS rights pickup':
      command     => "${feed_perl} ${feed_jobs}/feed.hourly/populate_rights_data.pl --pickup \
--screen --level INFO 2>&1 >> ${rights_log}",
      environment => $base_env + [ "HTFEED_CONFIG=${rights_db_config}" ],
      minute      => 25;

    # Queue volumes for conversion on GRIN and check their statuses
    'GRIN conversion / status check':
      command => "${feed_perl} ${feed_jobs}/feed.hourly/ready_from_grin.pl 2>&1 > /dev/null",
      minute  => 30;

    ## DAILY JOBS

    # mail previous days' rights load summary
    'mail rights load summary':
      command => "/usr/bin/mail -s \"Rights load summary\" ${recipient} < ${rights_log};\
 mv ${rights_log} ${feed_log}/populate_rights_`date +\"\\%Y\\%m\\%d\"`.log",
      hour    => 23,
      minute  => 59;

    # summary of previous day's ingest activity
    'ingest summary':
      command => "/bin/bash ${feed_daily}/ingest_summary.sh",
      hour    => 0,
      minute  => 5;

    # run daily tasks: update grin, get bibrecords, queue new material, deposit rights
    'daily tasks':
      command => "for script in ${feed_daily}/enabled/*.pl; do ${feed_perl} \$script; done",
      hour    => 3,
      minute  => 0;

    # copy crms renewals from latte-1
    'crms renewals':
      command => "/usr/bin/rsync ${crms_renewals_source} ${crms_renewals_dest}",
      hour    => 4,
      minute  => 5;

    'copy google rejects list':
      command     => "${feed_daily}/copy_rejects.sh",
      environment => "MAILTO=${joined_dcu_recipients}",
      hour        => 3,
      minute      => 5;

    ## WEEKLY JOBS

    'get brittle books data':
      command => "${feed_perl} ${feed_jobs}/feed.weekly/get_brittle_books_data.pl 2>&1 > /dev/null",
      weekday => 1,
      hour    => 8,
      minute  => 0;

    'generate ingest logs':
      command =>  "${feed_perl} ${feed_jobs}/feed.weekly/generate_logs.pl",
      weekday => 1,
      hour    => 1,
      minute  => 0;

    'generate ingest reports':
      command => "${feed_perl} ${feed_jobs}/feed.weekly/ingest_reporting.pl",
      weekday => 1,
      hour    => 2,
      minute  => 0;

    'repository statistics':
      command => "/bin/bash ${feed_jobs}/feed.weekly/repostat.sh",
      weekday => 1,
      hour    => 0,
      minute  => 0;

    'audit statistics':
      command => "/bin/bash ${feed_jobs}/feed.weekly/auditstat.sh",
      weekday => 1,
      hour    => 0,
      minute  => 5;

    ## MONTHLY JOBS
    ########## MONTHLY ############

    # Set volumes that are VIEW_FULL on GRIN but ic or und in the rights DB to
    # pdus/gfv, and reset volumes that are pdus/gfv but not VIEW_FULL on GRIN to
    # their bib-determined rights

    # not sure if this is still needed: "disposition 0 volumes"
    'grin reports':
      command  => "${feed_perl} ${feed_jobs}/feed.monthly/grin_reports.pl",
      monthday => 8,
      hour     => 1,
      minute   => 1;

    'grin gfv':
      command     => "${feed_perl} ${feed_jobs}/feed.monthly/grin_gfv.pl",
      environment => $base_env + [ "HTFEED_CONFIG=${rights_db_config}" ],
      monthday    => 29,
      hour        => 1,
      minute      => 1;

    'all sources':
      command  => "/bin/bash ${feed_jobs}/feed.monthly/all_sources.sh",
      monthday => 1,
      hour     => 2,
      minute   => 40;

    'generate dpla log':
      command  => "/bin/bash ${stats_home}/bin/generate_dpla_log.sh",
      monthday => 1,
      hour     => 2,
      minute   => 35;

    # unneeded?
    # 30 2 1 * * /bin/bash $FEED_HOME/bin/feed.monthly/grin_pod.sh

    # TO REWRITE
    # 25 2 1 * * /bin/bash $FEED_HOME/bin/feed.monthly/grin_error_range.sh

    'monthly ingest count':
      command  => "${feed_perl} ${feed_jobs}/feed.monthly/monthly_ingest_count.pl",
      monthday => 1,
      hour     => 2,
      minute   => 20;

    'copyright distribution snapshot':
      command  => "${feed_perl} ${feed_jobs}/feed.monthly/copyright_distribution_snapshot.pl",
      monthday => 1,
      hour     => 2,
      minute   => 10;

    'full zephir comparison':
      command  => "${feed_perl} ${feed_jobs}/feed.monthly/zephir_diff.pl",
      monthday => 1,
      hour     => 4,
      minute   => 0;

  }


}
