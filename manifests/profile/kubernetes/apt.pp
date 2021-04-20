# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::kubernetes::apt {
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
