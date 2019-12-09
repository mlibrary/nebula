# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Target host for applications that run inside docker containers
#
# To assign named instances to one of these hosts, use the
# nebula::profile::named_instances::docker::instances setting in the
# control repository. For example:
#
#     nebula::profile::named_instances::docker::instances:
#       app1:
#         image: mlibrary/app1:v1.2.3
#         host_port: 1234
#       app2:
#         image: registry-001.umdl.umich.edu:5000/app2:latest
#         host_port: 2468
#         container_port: 80
#
# Since app1 doesn't specify a host, it'll default to docker hub. Since
# it doesn't specify a container port, it'll bind 3000 in the container
# to 1234 on the host. Each host port must be different per node, but
# otherwise they can be anything that isn't taken.
class nebula::role::app_host::docker ()
{
  include nebula::role::minimal_docker
  include nebula::profile::named_instances::docker
}
