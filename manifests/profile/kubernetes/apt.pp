# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::kubernetes::apt {
  apt::source { 'kubernetes':
    location => 'https://apt.kubernetes.io/',
    release  => 'kubernetes-xenial',
    repos    => 'main',
    key      => {
      'id'     => '54A647F9048D5688D7DA2ABE6A030B21BA07F4FB',
      'source' => 'https://packages.cloud.google.com/apt/doc/apt-key.gpg',
    },
  }
}
