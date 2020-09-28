# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::role::clearinghouse
#
# AWS host with apache, mysql, php
#
# @example
#   include nebula::role::app_host::standalone
class nebula::role::clearinghouse {
  include nebula::role::aws

  include nebula::profile::mysql
  include nebula::profile::clearinghouse::apache
  include nebula::profile::clearinghouse::s3backup
  package { ['git',
  'clamav','clamav-daemon','clamdscan',
  'libimage-exiftool-perl',
  'poppler-utils',
  'php7.3-tidy' ]: }

}
