# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::moku
#
# @example
#   include nebula::profile::moku
class nebula::profile::moku (
  String $init_directory = '/etc/moku/init'
) {

  create_resources(nebula::named_instance,
    lookup('nebula::named_instances'),
    { init_directory =>  $init_directory }
  )

  Concat_fragment <<| target == "${name} deploy init" |>>

  Nebula::Named_instance::Moku_solr_params <<| |>>
}
