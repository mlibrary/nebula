# Puppet Server config
#
# @example
#   include nebula::profile::puppet::server
class nebula::profile::puppet::server (
) {
  ensure_packages([
    'openvox-server',
    'g10k',
  ])
  service { 'puppetserver':
    ensure  => running,
    enable  => true,
    require => Package['openvox-server'],
  }
}
