# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::clearinghouse::s3backup
#
# Configure s3 backup cron for Clearinghouse
#
# @example
#   include nebula::profile::clearinghouse::s3backup

class nebula::profile::clearinghouse::s3backup (
  String $mail_recipient = lookup('nebula::automation_email'),
  String $clearinghouse_filesystem = '/clearinghouse',
  String $backup_path = 'clearinghouse',
  String $bucket
) {

  ensure_packages(['awscli'])

  cron {
    default:
      environment => ["MAILTO=${mail_recipient}"],
      user        => 'root';

    'upload /clearinghouse to s3':
      command => "/usr/bin/aws s3 sync --delete --quiet ${clearinghouse_filesystem} ${bucket}/${backup_path}",
      day     => 7,
      minute  => 21,
      hour    => 1
  }

}
