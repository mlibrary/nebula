
# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::cron::catalog
#
# hathitrust.org catalog cron jobs
#
# @example
#   include nebula::profile::hathitrust::cron::catalog
class nebula::profile::hathitrust::cron::catalog (
  String $mail_recipient,
  String $user = 'libadm',
  String $catalog_home = '/htapps/catalog/web'
) {

  cron {
    default:
      user        => $user,
      environment => ["MAILTO=${mail_recipient}"];

    # Clean out the session information stored in the database. Sessions are
    # renewed every time there's any activity on them, and change after the timeout is reached.
    #
    # Note that this only needs to be run in one datacenter, since the mysql setup is master-master.
    #
    # We target only those sessions that have expired.

    'clean sessions':
      minute  => [0,15,30,45],
      command => "/usr/bin/perl ${catalog_home}/derived_data/clean_sessions.pl";

    # Build up translation maps. Collection codes are pulled from the HT
    # database, and lists of languages and formats are pulled right out of the the solr data.

    'translation maps':
      minute  => '58',
      hour    => '15',
      command => "${catalog_home}/derived_data/getall.sh ${catalog_home}/derived_data"
  }

}
