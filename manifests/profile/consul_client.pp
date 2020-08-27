# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::consul_client (
  String $organization,
) {
  package { 'consul':
    require => Apt::Source['hashicorp'],
  }

  apt::source { 'hashicorp':
    location => 'https://apt.releases.hashicorp.com',
    release  => fact('os.distro.codename'),
    repos    => 'main',
    key      => {
      'id'     => 'E8A032E094D8EB4EA189D270DA418C88A3219F7B',
      'source' => 'https://apt.releases.hashicorp.com/gpg',
    },
  }
}
