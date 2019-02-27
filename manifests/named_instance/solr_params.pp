# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::named_instance::solr_params
#
# Information about a solr core to be used by a named instance
# Used on the deployment host; exports the resource used to create the actual core.
#
# @example
#   include nebula::named_instance::solr_params
define nebula::named_instance::solr_params  (
  String $instance,
  String $path,
  Hash $solr_params,
) {

  $defaults = {
    host          => 'localhost',
    port          => 8081,
    instance      => $instance,
    instance_path => $path,
  }

  $merged_params = $defaults + $solr_params

  @@nebula::named_instance::solr_core { $title:
    *              => $merged_params
  }

  $port = $merged_params['port']
  $host = $merged_params['host']
  $index = $merged_params['index']
  $url  = "http://${host}:${port}/solr/${title}"

  concat_fragment { "${instance} deploy init infrastructure.solr.${index}":
    content => { infrastructure => { solr => { $index => $url }}}.to_json,
    target  => "${instance} deploy init"
  }
}
