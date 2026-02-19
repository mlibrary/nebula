# configure apt repo for nodejs
#
# This is a no-op if you choose the version of nodejs shipped by
# your OS vendor.
#
# Don't expect default version to remain static. Use an explicit version
# when calling this class if you don't want it upgraded.
class nebula::profile::apt::nodejs (
  Integer $version = 22,
) {
  $dist_version = $facts['os']['distro']['codename'] ? {
    'jammy'    => 12,
    'bullseye' => 12,
    'bookworm' => 18,
    'noble'    => 18,
    'trixie'   => 20,
    default    => 9999
  }

  $requested = $version

  if $requested > $dist_version {
    if $requested < 16 {
      fail("Can't configure apt for nodejs older than 16! Requested: ${requested}")
    }

    apt::source { 'nodesource.com':
      source_format => 'sources',
      comment       => 'Nodesource apt source for recent nodejs',
      location      => ["https://deb.nodesource.com/node_${requested}.x"],
      release       => 'nodistro',
      repos         => ['main'],
      keyring       => '/etc/apt/keyrings/nodesource.asc',
      architecture  => $facts['os']['architecture'],
    }

    apt::keyring { 'nodesource.asc':
      source => 'puppet:///modules/nebula/apt/keyrings/nodesource.asc',
    }
  } elsif $requested == $dist_version {
    warning("Skipping nodejs apt source: ${requested} is your OS default!")
  } elsif $requested < $dist_version {
    # We could do this if it's really needed. Would require
    # adding logic to configure apt rules.
    fail("Can't install nodejs ${requested}, your distro ships ${dist_version}!")
  }
}
