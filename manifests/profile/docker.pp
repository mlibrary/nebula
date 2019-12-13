# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Docker general profile
#
# This installs docker and sets its CRI to systemd instead of the
# default cgroupfs. See ADR-2 for an explanation of why.
#
# To see a list of docker versions available on the machine in question,
# you can run `apt-cache madison docker-ce`.
#
# @param version Optional version of docker to install.
#
# @example Installing docker if you don't require a particular version
#   include nebula::profile::docker
#
# @example Installing a particular version of docker
#   class { 'nebula::profile::docker':
#     version => '18.06.2~ce~3-0~debian',
#   }
class nebula::profile::docker (
  String $version = '',
) {
  concat_file { 'cri daemon':
    path    => '/etc/docker/daemon.json',
    format  => 'json',
    require => File['/etc/docker'],
    notify  => Exec['docker: systemctl daemon-reload'],
  }

  concat_fragment {
    default:
      target => 'cri daemon',
    ;

    'cri daemon exec-opts':
      content => '{"exec-opts":["native.cgroupdriver=systemd"]}',
    ;

    'cri daemon log-driver':
      content => '{"log-driver":"json-file"}',
    ;

    'cri daemon log-opts':
      content => '{"log-opts":{"max-size":"100m"}}',
    ;

    'cri daemon storage-driver':
      content => '{"storage-driver":"overlay2"}',
    ;
  }

  file { '/etc/docker':
    ensure => 'directory',
  }

  exec { 'docker: systemctl daemon-reload':
    command     => '/bin/systemctl daemon-reload',
    refreshonly => true,
    notify      => Service['docker'],
    subscribe   => File['/etc/systemd/system/docker.service.d'],
  }

  if $version == '' {
    class { 'docker':
      extra_parameters => [
        '--insecure-registry=docker-registry.umdl.umich.edu:80',
      ],
    }
  } else {
    class { 'docker':
      version          => $version,
      extra_parameters => [
        '--insecure-registry=hatcher-kubernetes.umdl.umich.edu:32030',
        '--insecure-registry=docker-registry.umdl.umich.edu:80',
      ],
    }

    apt::pin { 'docker-ce':
      packages => ['docker-ce', 'docker-ce-cli'],
      version  => $version,
      priority => 999,
    }
  }
}
