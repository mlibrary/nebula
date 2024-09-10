
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
  String $catalog_home = '/htapps/catalog/web',
  Integer $mdp_sessions_minute = 5,
  $sdr_environment = [
    "SDRROOT=${sdr_root}",
    "SDRDATAROOT=${sdr_data_root}",
    "HOME=${home}"
  ]
) {

  cron {
    default:
      user        => $user,
      environment => $sdr_environment + ["MAILTO=${mail_recipient}"];

    # Mail /htapps/babel/logs/assert/hathitrust=email-digest-current at 15 minute intervals

    'assert failure mail digest':
      minute  => [15,30,45,59],
      command => "eval ${sdr_root}/mdp-misc/scripts/email-monitor.pl";

    'manage mbook sessions':
      minute      => $mdp_sessions_minute,
      environment => $sdr_environment + ["MAILTO=''"],
      command     => "${home}/scripts/managembookssessions.pl -m clean -a 120 2>&1 || /usr/bin/mail -s '${::hostname} managembooksessions error' ${mail_recipient}";

    'manage exclusivity expiration':
      minute  => $mdp_sessions_minute,
      command => "${sdr_root}/pt/scripts/manage_exclusivity.pl";

    'harvest proxy downloads':
      minute      => 01,
      hour        => 00,
      environment => $sdr_environment + ["MAILTO=''"],
      command     => "${sdr_root}/pt/scripts/harvest_proxy_downloads.pl 2>&1 || /usr/bin/mail -s '${::hostname} harvest_proxy_downloads problems' ${mail_recipient}";

    # Build up translation maps. Collection codes are pulled from the HT
    # database, and lists of languages and formats are pulled right out of the the solr data.

    'translation maps':
      minute  => '58',
      hour    => '15',
      command => "${catalog_home}/derived_data/getall.sh ${catalog_home}/derived_data";

    'merge application logs':
      minute  => 05,
      command => "${home}/scripts/merge_application_logs.pl";

  }

}
