# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Frobscottle
class nebula::role::app_host::datamart {
  include nebula::role::umich
  include nebula::profile::ruby
}
