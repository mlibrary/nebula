# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Minimal subset of www_lib_cron_vm role to run maintenace crons for www.lib.umich.edu
#
# @example
#   include nebula::role::webhost::www_lib_cron_vm
class nebula::role::webhost::www_lib_cron_vm (
  String $private_address_template = '192.168.0.%s',
  Hash $hosts = {}
) {
  include nebula::role::umich

  class { 'nebula::profile::networking::private':
    address_template => $private_address_template
  }

  include nebula::profile::www_lib::mounts

  create_resources('host',$hosts)

  include nebula::profile::www_lib::php
}
