# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::moku
#
# @example
#   include nebula::profile::moku
class nebula::profile::moku {
  lookup('nebula::named_instances').each |$key, $instance| {
    # Collect exported `moku init` exec resources. These are exported by
    # named_instance resources.
    Exec <<| command == "moku init < '/tmp/.moku_init_${key}.json'" |>>

    $path = $instance['path']
    if has_key($instance, 'subservices') {
      $subservices = $instance['subservices']
    } else {
      $subservices = []
    }

    file { "/tmp/.moku_init_${key}.json":
      ensure  => 'present',
      content => template('nebula/profile/moku/init.json.erb'),
    }
  }
}
