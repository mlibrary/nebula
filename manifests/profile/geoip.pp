
# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::geoip
#
# Install and configure geoip geolocation service
#
# @example
#   include nebula::profile::geoip
class nebula::profile::geoip () {
  package { 'geoip-bin': }
}
