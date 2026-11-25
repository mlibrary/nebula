class nebula::profile::unattended_upgrades {
  class { 'unattended_upgrades':
    extra_origins                      => [
      'origin=*', # match every origin
      'site=*',   # match [the annoyingly common] missing origin
    ],
    only_on_ac_power                   => false,
    skip_updates_on_metered_connection => false,
  }
}
