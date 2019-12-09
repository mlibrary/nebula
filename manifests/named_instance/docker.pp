# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Named instance docker container
#
# @param image The image to run. This will need to include the registry
#   if it's anything other than the docker hub, and it should contain
#   the version tag.
# @param host_port The port that will be exposed to Apache on the host
#   machine. This needs to be unique for each named instance sharing the
#   same host.
# @param container_port Optional port to expose from the container's
#   perspective. Default is 3000.
define nebula::named_instance::docker (
  String  $image,
  Integer $host_port,
  Integer $container_port = 3000,
) {
  require nebula::profile::docker

  docker::run { $title:
    image => $image,
    ports => "${host_port}:${container_port}",
  }
}
