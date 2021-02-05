# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::clamav
#
# Install clamav dependencies for HT ingest
#
# @example
#   include nebula::profile::hathitrust::clamav
class nebula::profile::hathitrust::clamav () {

  ensure_packages (
    [
      'clamav-daemon',
      'libclamav-client-perl'
    ]
  )

  service { 'clamav-daemon':
    ensure => 'running',
    enable => true,
  }

  service { 'clamav-freshclam':
    ensure =>  'running',
    enable => true,
  }

}
