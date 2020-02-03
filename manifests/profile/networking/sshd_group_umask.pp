# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::networking::sshd_group_umask
#
# Ensure that the umask is set to allow scp/rsync files to carry group
# permissions (0002). This adjusts the PAM sshd config under /etc/pam.d.
#
# @example
#   include nebula::profile::networking::sshd_group_umask
class nebula::profile::networking::sshd_group_umask () {
  # Ensure that group-write umask is set for uploaders.
  concat_fragment { '/etc/pam.d/sshd: group umask':
    target  => '/etc/pam.d/sshd',
    content => @("EOT")

      # Allow rsync transfers to set group write
      session    optional   pam_umask.so umask=0002
      | EOT
  }
}
