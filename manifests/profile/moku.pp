# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::moku
#
# @example
#   include nebula::profile::moku
class nebula::profile::moku (
  String $init_directory = '/etc/moku/init'
) {

  file { $init_directory:
    ensure => 'directory',
  }

  create_resources(nebula::named_instance,
    lookup('nebula::named_instances'),
    { init_directory =>  $init_directory }
  )

  package { 'kubectl':
    require => Apt::Source['kubernetes'],
  }

  apt::source { 'kubernetes':
    location => 'https://apt.kubernetes.io/',
    release  => 'kubernetes-xenial',
    repos    => 'main',
    key      => {
      'id'     => '7F92E05B31093BEF5A3C2D38FEEA9169307EA071',
      'source' => 'https://packages.cloud.google.com/apt/doc/apt-key.gpg',
    },
  }
}
