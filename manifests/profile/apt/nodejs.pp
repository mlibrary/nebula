# configure apt repo for nodejs
#
# This is a no-op if you choose the version of nodejs shipped by
# your OS vendor.
#
# For nodejs >= 16, uses updated repo and apt key which is required to get
# current updates, and to get nodejs >= 22 at all.
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
    if $requested < 14 {
      fail("Can't configure apt for nodejs older than 14! Requested: ${requested}")
    }
    if $requested < 16 {
      $release = $facts['os']['distro']['codename']
      $keyring = 'puppet:///modules/nebula/apt/keyrings/nodesource0.asc'
    } else {
      $release = 'nodistro'
      $keyring = 'puppet:///modules/nebula/apt/keyrings/nodesource.asc'
    }

    apt::source { 'nodesource.com':
      source_format => 'sources',
      comment       => 'Nodesource apt source for recent nodejs',
      location      => ["https://deb.nodesource.com/node_${requested}.x"],
      release       => $release,
      repos         => ['main'],
      keyring       => '/etc/apt/keyrings/nodesource.asc',
    }

    apt::keyring { 'nodesource.asc':
      source => $keyring,
    }
  } elsif $requested == $dist_version {
    warning("Skipping nodejs apt source: ${requested} is your OS default!")
  } elsif $requested < $dist_version {
    # We could do this if it's really needed. Would require
    # adding logic to configure apt rules.
    fail("Can't install nodejs ${requested}, your distro ships ${dist_version}!")
  }
}
