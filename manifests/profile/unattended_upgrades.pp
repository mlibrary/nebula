class nebula::profile::unattended_upgrades {
  class { 'unattended_upgrades':
    extra_origins                      => [
      'origin=Vox Pupuli',
    ],
    only_on_ac_power                   => false,
    skip_updates_on_metered_connection => false,
  }
}
