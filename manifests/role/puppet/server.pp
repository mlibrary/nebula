# Puppet Server
#
# @example
#   include nebula::role::puppet::server
class nebula::role::puppet::server {
  include nebula::role::minimum
  include nebula::profile::puppet::server
}
