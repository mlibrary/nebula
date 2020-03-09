
# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::cron::mdp_misc
#
# hathitrust.org mdp_misc cron jobs
#
# @example
#   include nebula::profile::hathitrust::cron::mdp_misc
class nebula::profile::hathitrust::cron::mdp_misc (
  String $mail_recipient,
  String $user = 'libadm',
  String $sdr_root = '/htapps/babel',
  String $sdr_data_root = '/sdr1',
  String $home = '/htapps/babel/mdp-misc',
  Integer $mdp_sessions_minute = 5
) {

  cron {
    default:
      user        => $user,
      environment => ["MAILTO=${mail_recipient}",
      "SDRROOT=${sdr_root}",
      "SDRDATAROOT=${sdr_data_root}",
      "HOME=${home}"];

    # Mail /htapps/babel/logs/assert/hathitrust=email-digest-current at 15 minute intervals

    'assert failure mail digest':
      minute  => [15,30,45,59],
      command => "eval ${sdr_root}/mdp-misc/scripts/email-monitor.pl";

    'data api log monitor':
      minute  => 59,
      hour    => 23,
      command => "${sdr_root}/htd/scripts/htdmonitor 2>&1 | /usr/bin/mail -s '${::hostname} htdmonitor output' ${mail_recipient}";

    'manage mbook sessions':
      minute  => $mdp_sessions_minute,
      command => "${home}/scripts/managembookssessions.pl -m clean -a 120 2>&1 | /usr/bin/mail -s '${::hostname} managembooksessions output' ${mail_recipient}";

    'harvest proxy downloads':
      minute  => 01,
      hour    => 00,
      command => "${sdr_root}/pt/scripts/harvest_proxy_downloads.pl 2>&1 | /usr/bin/mail -s '${::hostname} harvest_proxy_downloads output' ${mail_recipient}";

  }

}
