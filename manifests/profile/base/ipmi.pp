# nebula::profile::base::ipmi
#
# add IPMI facts to puppetdb
# TODO: export resource for drac/ilo ip, hostname
# TODO: add ipmi configuration (manage users, etc)
#
# @example
#   include nebula::profile::base::impi
class nebula::profile::base::ipmi
{
  class { 'ipmi':
    service_ensure         => 'stopped',
    ipmievd_service_ensure => 'stopped',
    watchdog               => false,
  }
}
