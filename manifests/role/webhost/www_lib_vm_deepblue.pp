# Copyright (c) 2019-2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Webhost hosting www.lib.umich.edu
#
# @example
#   include nebula::role::webhost::www_lib
class nebula::role::webhost::www_lib_vm_deepblue (
  String $private_address_template = '192.168.0.%s',
  Hash $hosts = {}
) {
  include nebula::role::webhost::www_lib_vm
  #include nebula::profile::www_lib::register_for_load_balancing_deepblue
}
