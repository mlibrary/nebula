# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::networking::firewall::http
#
# Manage firewall (iptables) settings for HTTP/s
#
# @example
#   include nebula::profile::networking::firewall::http
class nebula::profile::networking::firewall::http () {
  Firewall <<| tag == 'haproxy' |>>
}
