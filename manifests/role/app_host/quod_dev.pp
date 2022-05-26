# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::role::app_host::quod_dev
#
# Application host (QUOD development)
#
# @example
#   include nebula::role::app_host::quod_dev
class nebula::role::app_host::quod_dev {
  include nebula::role::umich
  include nebula::profile::krb5
  include nebula::profile::afs
  include nebula::profile::users
  include nebula::profile::ruby
  include nebula::profile::nodejs
  include nebula::profile::named_instances
  include nebula::profile::tsm
  include nebula::profile::quod::dev::perl
  include nebula::profile::prometheus::exporter::mysql
  include nebula::profile::tesseract
}
