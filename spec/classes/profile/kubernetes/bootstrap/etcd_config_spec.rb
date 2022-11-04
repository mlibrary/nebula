# frozen_string_literal: true

# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::kubernetes::bootstrap::etcd_config' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/first_cluster_config.yaml' }
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it do
        is_expected.to contain_file('/etc/systemd/system/kubelet.service.d/20-etcd-service-manager.conf')
          .with_content(%r{^ExecStart=/usr/bin/kubelet --address=127.0.0.1 --pod-manifest-path=/etc/kubernetes/manifests --cgroup-driver=systemd$})
          .that_notifies('Exec[kubelet reload daemon]')
          .that_requires('Package[kubelet]')
          .that_requires('File[/etc/systemd/system/kubelet.service.d]')
      end

      it { is_expected.to contain_file('/etc/systemd/system/kubelet.service.d').with_ensure('directory') }

      it do
        is_expected.to contain_exec('kubelet reload daemon')
          .with_command('/bin/systemctl daemon-reload')
          .with_refreshonly(true)
          .that_notifies('Service[kubelet]')
      end

      it { is_expected.to contain_file('/tmp/etcd.yaml') }

      context 'with cluster set to second_cluster' do
        let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/second_cluster_config.yaml' }

        it { is_expected.not_to contain_file('/tmp/etcd.yaml') }
      end
    end
  end
end
