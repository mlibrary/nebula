# Copyright (c) 2023 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::unattended_upgrades {
  class { 'unattended_upgrades':
    extra_origins => [
      'origin=Puppetlabs,codename=${distro_codename},label=Puppetlabs',
    ],
    only_on_ac_power => false,
  }

  file { '/etc/apt/apt.conf.d/51unattended-upgrades-extra':
    content => 'Unattended-Upgrade::Skip-Updates-On-Metered-Connections "false";'
  }
}
