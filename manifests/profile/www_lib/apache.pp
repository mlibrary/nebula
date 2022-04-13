# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::www_lib::apache
#
# Compatibility profile for www-lib Apache applications. This is only here to
# allow for any hiera config and $default_access references throughout nebula
# to be retargeted. This is effectively a global constant for those nodes that
# include the profile.
#
# All of the actual resources have been moved to base, misc, or more specific
# profiles.
#
# @param $default_access Default access rules to use for server documentroots.
#   Should be in the format as accepted by the 'require' parameter for
#   directories for apache::vhost, for example: $default_access = 'all granted'
#
# @example
#   include nebula::profile::www_lib::apache
class nebula::profile::www_lib::apache (
  Variant[Hash,String] $default_access = {
    enforce  => 'all',
    requires => [
      'not env badrobot',
      'not env loadbalancer',
      'all granted'
    ]
  }
) {
}
