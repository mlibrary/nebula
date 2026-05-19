# Puppet Server config
#
# @example
#   include nebula::profile::puppet::server
class nebula::profile::puppet::server () {
  ensure_packages([
    'g10k',
  ])
}
