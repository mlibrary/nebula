# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::imagemagick
#
# Configure ImageMagick. Increase its default limits in its policy.xml.
#
# @example
#   include nebula::profile::imagemagick
class nebula::profile::imagemagick {
  package { 'imagemagick': }

  file { '/etc/ImageMagick-6/policy.xml':
    content => template('nebula/profile/imagemagick/policy.xml.erb'),
    require => Package['imagemagick'],
  }
}
