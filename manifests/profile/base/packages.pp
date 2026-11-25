# nebula::profile::base::packages
#
# Install misc. base packages that don't require any further config.
#
# @example
#   include nebula::profile::base::packages
class nebula::profile::base::packages {
  # TODO: this line may be removed at any time after it has been merged
  package { 'duo-unix': ensure => absent }

  stdlib::ensure_packages([
    'fd-find',
    'ripgrep',
    'zstd',
  ])
  file { '/usr/local/bin/fd':
    ensure  => link,
    target  => '/usr/bin/fdfind',
    require => Package['fd-find'],
  }

  if $facts['os']['distro']['codename'] in ['noble', 'bookworm'] {
    # nothing left to do but complain
    notice("/usr/bin/last provided by 'util-linux' on ${facts['os']['distro']['codename']}; wtmpdb will not be installed")
  } else {
    # `/usr/bin/last` provided by `wtmpdb` on Debian 13 / Ubuntu 24.10 and later
    stdlib::ensure_packages(['libpam-wtmpdb', 'wtmpdb'])
  }
}
