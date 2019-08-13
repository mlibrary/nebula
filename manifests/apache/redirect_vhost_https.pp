# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

define nebula::apache::redirect_vhost_https (
  Array[String] $serveraliases = [],
  String $target = "https://www.${title}",
  String $common_name = $title,
) {
  apache::vhost { "${title}-https":
    tag             => "ssl-${common_name}",
    port            => '443',
    docroot         => false,
    servername      => $title,
    serveraliases   => $serveraliases,
    redirect_source => '/',
    redirect_status => 'permanent',
    redirect_dest   => $target,
  }
}
