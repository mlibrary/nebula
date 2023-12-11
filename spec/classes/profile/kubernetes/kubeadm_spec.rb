# frozen_string_literal: true

# Copyright (c) 2019-2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::kubernetes::kubeadm' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with cluster set to first_cluster' do
        let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/first_cluster_config.yaml' }

        it { is_expected.to compile }

        it { is_expected.to contain_package('kubeadm').with_ensure('1.14.2-00') }
        it { is_expected.to contain_package('kubeadm').that_requires('Apt::Source[kubernetes]') }

        it do
          is_expected.to contain_apt__pin('kubeadm').with(
            packages: ['kubeadm'],
            version: '1.14.2-00',
            priority: 999,
          )
        end
      end

      context 'with cluster set to second_cluster' do
        let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/second_cluster_config.yaml' }

        it { is_expected.to contain_package('kubeadm').with_ensure('1.11.9-00') }
        it { is_expected.to contain_apt__pin('kubeadm').with_version('1.11.9-00') }

        it do
          is_expected.to contain_file('/etc/sysctl.d/kubernetes_cluster.conf')
            .with_content(%r{^fs\.inotify\.max_user_instances *= *8192$})
            .that_notifies('Service[procps]')
        end

        it do
          is_expected.to contain_file('/etc/sysctl.d/kubernetes_cluster.conf')
            .with_content(%r{^fs\.inotify\.max_user_watches *= *524288$})
            .that_notifies('Service[procps]')
        end
      end
    end
  end
end
