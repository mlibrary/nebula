# nebula::profile::plenary_utils
#
# Install cli utils for live debugging of servers that __should__ be installed
# everywhere. Things you don't __need__, but are nice to have. If you've run
# `apt install $PACKAGE` on a package during an outage more that 1-2 times,
# that package __may__ belong here.
#
# * This is not the place for anything a service depends on.
# * Only tools w/ low footprint, 0 dependencies, tiny install (<=2MiB), etc.
#
# @example
#   include nebula::profile::plenary_utils
class nebula::profile::plenary_utils {
  stdlib::ensure_packages([
    'fd-find',
    'ripgrep',
  ])
  file { '/usr/local/bin/fd':
    ensure  => link,
    target  => '/usr/bin/fdfind',
    require => Package['fd-find'],
  }
}
