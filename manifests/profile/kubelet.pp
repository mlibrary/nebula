# Copyright (c) 2023 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
class nebula::profile::kubelet (
  String $kubelet_version,
  String $pod_manifest_path = "/etc/kubernetes/manifests",
  Boolean $use_pod_manifest_path = true,
) {
  include nebula::profile::networking::sysctl
  include nebula::profile::containerd
  include nebula::profile::kubernetes::apt

  kmod::load { "overlay": }
  kmod::load { "br_netfilter": }

  file { "/etc/sysctl.d/kubelet.conf":
    content => template("nebula/profile/kubernetes/kubelet_sysctl.conf.erb"),
    notify  => Service["procps"],
  }

  package { "kubelet":
    ensure  => $kubelet_version,
    require => Apt::Source["kubernetes"],
  }

  apt::pin { "kubelet":
    packages => ["kubelet"],
    version  => $kubelet_version,
    priority => 999,
  }

  service { "kubelet":
    ensure  => "running",
    enable  => true,
    require => Package["kubelet"],
  }

  if $use_pod_manifest_path {
    file { "/etc/systemd/system/kubelet.service.d":
      ensure => "directory",
    }

    file { "/etc/systemd/system/kubelet.service.d/20-containerd-and-manifest-dir.conf":
      content => template("nebula/profile/kubelet/systemd.conf.erb"),
      require => Package["kubelet"],
      notify  => Exec["kubelet reload daemon"],
    }

    exec { 'kubelet reload daemon':
      command     => "/bin/systemctl daemon-reload",
      refreshonly => true,
      notify      => Service["kubelet"],
    }
  }
}
