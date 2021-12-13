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
  String $recipient,
  String $rights_db_config,
  String $rights_log = '/tmp/populate_rights.log'
) {

  package { 'heirloom-mailx': }

  $feed_perl = "/usr/bin/perl -I ${feed_home}/lib"
  $feed_jobs = "${feed_home}/bin/jobs"
  $feed_daily = "${feed_jobs}/feed.daily"
  $feed_log  = "${feed_home}/var/log"
  $base_env = [
    "MAILTO=${recipient}",
    "FEED_HOME=${feed_home}"
  ]


  cron {
    default:
      environment => $base_env + [ "HTFEED_CONFIG=${config}" ],
      user        => 'libadm';

    'generate dpla log':
      command  => "/bin/bash ${stats_home}/bin/generate_dpla_log.sh",
      monthday => 1,
      hour     => 2,
      minute   => 35;

    'full zephir comparison':
      ensure   =>  'absent';

  }


}
