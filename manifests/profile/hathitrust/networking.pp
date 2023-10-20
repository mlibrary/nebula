# network configuration for hathitrust.org
#
# @example
#   include nebula::profile::hathitrust::networking
class nebula::profile::hathitrust::networking (
  String $private_address_template = '192.168.0.%s',
) {
  class { 'nebula::profile::networking::private':
    address_template => $private_address_template
  }
}
