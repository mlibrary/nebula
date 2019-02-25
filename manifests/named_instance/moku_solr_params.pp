# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::moku
#
# @example
#   include nebula::profile::moku
define nebula::named_instance::moku_solr_params  (
  String $instance,
  String $url,
  Integer $index
) {

  ensure_resource('concat_fragment',
    "${instance} deploy init infrastructure.solr.${index}",
    {
      content => { infrastructure => { solr => { $index => $url }}}.to_json,
      target  => "${instance} deploy init"
    }
  )
}
