# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Wrapper for puma
# It uses bundled puma if present, system puma otherwise
# It prefers the moku puma config over the default location
#
# @example
class nebula::profile::named_instances::puma_wrapper(
  String  $path,
  String  $rbenv_root,
  String  $puma_config,
){
  file { $path:
    ensure  => 'present',
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    content => template('nebula/profile/named_instances/puma_wrapper/script.erb'),
  }
}
