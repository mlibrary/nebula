# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Profile for a docker-based named instance host
#
# @param instances This should be a hash keyed on the names of the named
#   instances. Each value should be a hash of parameters to pass to
#   nebula::named_instance::docker. See that file for documentation on
#   each of those settings.
class nebula::profile::named_instances::docker (
  Hash[String, Hash] $instances = {},
) {
  $instances.each |$name, $settings| {
    nebula::named_instance::docker {
      $name:
        * => $settings,
      ;
    }
  }
}
