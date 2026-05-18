class nebula::profile::unattended_upgrades {
  class { 'unattended_upgrades':
    extra_origins                      => [
      'origin=mlibrary',
      'origin=Docker',            # containerd
      'site=pkg.duosecurity.com', # duo
      'origin=HPE',               # hpe
      'origin=elastic',           # filebeat, metricbeat
      'site=apt.grafana.com',     # grafana alloy
      'origin=XamarinBuster',     # mono
      'origin=nginx',             # nginx
      'site=deb.nodesource.com',  # nodejs
      'origin=Artifactory',       # openjdk
      'origin=Vox Pupuli',        # openvox
      'origin=deb.sury.org',      # php
      'origin=yarn',              # yarn
    ],
    only_on_ac_power                   => false,
    skip_updates_on_metered_connection => false,
    blacklist                          => [
      'falcon-sensor',
      'apache2','apache2-bin','apache2-data','apache2-utils',
      'mariadb-server','mariadb-server-.*',
    ],
  }
}
