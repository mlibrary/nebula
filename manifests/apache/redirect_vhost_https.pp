# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

define nebula::apache::redirect_vhost_https (
  Array[String] $serveraliases = [],
  String $target = "https://www.${title}/",
  $priority = false,
) {
  nebula::apache::redirect_vhost_http { "${title}":
    serveraliases => $serveraliases
  }
  apache::vhost { "${title}-redirect-https":
    port            => '443',
    priority        => $priority,
    docroot         => false,
    servername      => $title,
    serveraliases   => $serveraliases,
    redirect_source => '/',
    redirect_status => 'permanent',
    redirect_dest   => $target,
  }
}
