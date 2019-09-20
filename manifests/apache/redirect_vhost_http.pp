# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

define nebula::apache::redirect_vhost_http (
  Array[String] $serveraliases = [],
  String $target = "http://www.${title}/",
  $priority = false,
) {
  apache::vhost { "${title}-redirect-http":
    port            => '80',
    priority        => $priority,
    docroot         => false,
    servername      => $title,
    serveraliases   => $serveraliases,
    redirect_source => '/',
    redirect_status => 'permanent',
    redirect_dest   => $target,
  }
}
