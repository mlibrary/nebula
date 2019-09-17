# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::role::clearinghouse
#
# Database host for ArchivesSpace backend storage
#
# @example
#   include nebula::role::app_host::standalone
class nebula::role::archivesspace::mysql {
  include nebula::profile::mysql
}
