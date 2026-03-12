class nebula::profile::unattended_upgrades {
  class { 'unattended_upgrades':
    extra_origins                      => [
      'origin=Vox Pupuli',
    ],
    only_on_ac_power                   => false,
    skip_updates_on_metered_connection => false,
  }

  # TODO: DELETE THIS
  # this file is no longer needed, this needs to run once on existing hosts
  file { '/etc/apt/apt.conf.d/51unattended-upgrades-extra':
    ensure => absent
  }
}
