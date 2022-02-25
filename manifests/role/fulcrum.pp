# Copyright (c) 2021-2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# This is a temporary compatibilty role for a complete, standalone Fulcrum server. nebula::role::fulcrum::standalone should be used directly instead.

class nebula::role::fulcrum {
  include nebula::role::fulcrum::standalone
}
