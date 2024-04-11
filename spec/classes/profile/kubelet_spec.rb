# frozen_string_literal: true

# Copyright (c) 2023 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::kubelet' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) { { kubelet_version: "invalid-example-version" } }

      it { is_expected.to compile }

      # Prerequisites according to kubernetes documentation:
      # https://kubernetes.io/docs/setup/production-environment/container-runtimes/
      it { is_expected.to contain_kmod__load("overlay") }
      it { is_expected.to contain_kmod__load("br_netfilter") }
      it { is_expected.to contain_file("/etc/sysctl.d/kubelet.conf").that_notifies("Service[procps]") }
      ["net.bridge.bridge-nf-call-iptables",
       "net.bridge.bridge-nf-call-ip6tables",
       "net.ipv4.ip_forward"].each do |param|
        it do
          is_expected.to contain_file("/etc/sysctl.d/kubelet.conf")
            .with_content(/^#{param} *= *1$/)
        end
      end

      it { is_expected.to contain_service("containerd") }

      it do
        is_expected.to contain_apt__source("kubernetes")
          .with_location("https://pkgs.k8s.io/core:/stable:/vX.YZ/deb/")
          .with_release("/")
      end

      it do
        is_expected.to contain_package("kubelet")
          .with_ensure("invalid-example-version")
          .that_requires("Apt::Source[kubernetes]")
      end

      it do
        is_expected.to contain_apt__pin("kubelet")
          .with_packages(["kubelet"])
          .with_version("invalid-example-version")
          .with_priority(999)
      end

      it do
        is_expected.to contain_service("kubelet")
          .with_ensure("running")
          .with_enable(true)
          .that_requires("Package[kubelet]")
      end

      context "with kubelet_version set to 1.2.3-00" do
        let(:params) { { kubelet_version: "1.2.3-00" } }

        it { is_expected.to contain_package("kubelet").with_ensure("1.2.3-00") }
        it { is_expected.to contain_apt__pin("kubelet").with_version("1.2.3-00") }
      end

      it do
        is_expected.to contain_exec("kubelet reload daemon")
          .that_notifies("Service[kubelet]")
          .with_refreshonly(true)
          .with_command("/bin/systemctl daemon-reload")
      end

      it do
        is_expected.to contain_file("/etc/kubernetes/manifests")
          .with_ensure("directory")
          .with_recurse(true)
          .with_purge(true)
          .that_requires("Package[kubelet]")
      end

      it do
        is_expected.to contain_file("/etc/systemd/system/kubelet.service.d")
          .with_ensure("directory")
          .that_requires("Package[kubelet]")
      end

      it do
        is_expected.to contain_file("/etc/systemd/system/kubelet.service.d/20-containerd-and-manifest-dir.conf")
          .that_requires("File[/etc/systemd/system/kubelet.service.d]")
          .that_requires("Package[kubelet]")
          .that_notifies("Exec[kubelet reload daemon]")
      end

      it do
        is_expected.to contain_file("/etc/systemd/system/kubelet.service.d/20-containerd-and-manifest-dir.conf")
          .with_content(/^Restart=always$/)
      end

      it do
        # This is important because we're using this file to override
        # the contents of the original systemd file. Without this empty
        # line, systemd might ignore our preferred ExecStart.
        is_expected.to contain_file("/etc/systemd/system/kubelet.service.d/20-containerd-and-manifest-dir.conf")
          .with_content(/^ExecStart=$/)
      end

      it do
        is_expected.to contain_file("/etc/systemd/system/kubelet.service.d/20-containerd-and-manifest-dir.conf")
          .with_content(/^ExecStart=\/usr\/bin\/kubelet --config=\/etc\/kubernetes\/kubelet\.yaml$/)
      end

      it do
        is_expected.to contain_file("/etc/kubernetes/kubelet.yaml")
          .with_content(/address:.*127.0.0.1/)
          .with_content(/staticPodPath:.*\/etc\/kubernetes\/manifests/)
          .with_content(/cgroupDriver:.*systemd/)
          .with_content(/containerRuntimeEndpoint:.*unix:\/\/\/run\/containerd\/containerd.sock/)
      end

      context "with pod_manifest_path set to /tmp/kubelet" do
        let(:params) { { kubelet_version: "123", pod_manifest_path: "/tmp/kubelet" } }

        it { is_expected.not_to contain_file("/etc/kubernetes/manifests") }
        it { is_expected.to contain_file("/tmp/kubelet") }

        it do
          is_expected.to contain_file("/etc/kubernetes/kubelet.yaml")
            .with_content(/staticPodPath:.*\/tmp\/kubelet/)
        end
      end

      context "with manage_pods_with_puppet set to false" do
        let(:params) { { kubelet_version: "123", manage_pods_with_puppet: false } }

        it { is_expected.not_to contain_file("/etc/kubernetes/manifests") }
        it { is_expected.not_to contain_file("/etc/systemd/system/kubelet.service.d") }
        it { is_expected.not_to contain_file("/etc/systemd/system/kubelet.service.d/20-containerd-and-manifest-dir.conf") }
        it { is_expected.not_to contain_exec("kubelet reload daemon") }
      end
    end
  end
end
