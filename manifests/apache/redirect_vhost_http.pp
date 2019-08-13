# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

define nebula::apache::redirect_vhost_http (
  String $servername,
  Array[String] $serveraliases = [],
  String $target = "http://www.${servername}",
) {
  apache::vhost { "${servername}-http":
    port            => '80',
    docroot         => false,
    servername      => $servername,
    serveraliases   => $serveraliases,
    redirect_source => '/',
    redirect_status => 'permanent',
    redirect_dest   => $target,
  }
}
