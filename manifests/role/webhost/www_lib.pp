# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Webhost hosting www.lib.umich.edu
#
# @example
#   include nebula::role::webhost::www_lib
class nebula::role::webhost::www_lib {
  nebula::balanced_frontend { 'www-lib': }
  nebula::balanced_frontend { 'deepblue': }
  include nebula::role::umich
  include nebula::profile::elastic::filebeat::prospectors::clickstream
}
