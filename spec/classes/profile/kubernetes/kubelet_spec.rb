# frozen_string_literal: true

# Copyright (c) 2019-2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::kubernetes::kubelet' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/first_cluster_config.yaml' }
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_kmod__load('br_netfilter') }

      it do
        is_expected.to contain_file('/etc/sysctl.d/kubelet.conf')
          .with_content(/^net.bridge.bridge-nf-call-ip6tables = 1\nnet.bridge.bridge-nf-call-iptables = 1\nnet.ipv4.ip_forward = 1/)
          .that_notifies('Service[procps]')
      end

      context 'with cluster unset' do
        let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/default_config.yaml' }

        it { is_expected.not_to compile }
      end

      context 'with cluster set to one without a kubernetes version' do
        let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/implicit_kubernetes_version_config.yaml' }

        it { is_expected.not_to compile }
      end

      context 'with cluster set to one without a public ip address' do
        let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/implicit_public_address_config.yaml' }

        it { is_expected.not_to compile }
      end

      context 'with cluster set to one without a router ip address' do
        let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/implicit_router_address_config.yaml' }

        it { is_expected.not_to compile }
      end

      context 'with cluster set to one without an etcd ip address' do
        let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/implicit_etcd_address_config.yaml' }

        it { is_expected.not_to compile }
      end

      context 'with cluster set to one without a kube-api ip address' do
        let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/implicit_kube_api_address_config.yaml' }

        it { is_expected.not_to compile }
      end

      context 'with cluster set to first_cluster' do
        let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/first_cluster_config.yaml' }

        it { is_expected.to contain_service('kubelet').with_ensure('running') }
        it { is_expected.to contain_service('kubelet').with_enable(true) }
        it { is_expected.to contain_service('kubelet').that_requires('Package[kubelet]') }

        it { is_expected.to contain_package('kubelet').with_ensure('1.14.2-1.1') }
        it { is_expected.to contain_package('kubelet').that_requires('Apt::Source[kubernetes]') }

        it do
          is_expected.to contain_apt__pin('kubelet').with(
            packages: ['kubelet'],
            version: '1.14.2-1.1',
            priority: 999,
          )
        end

        it do
          is_expected.to contain_apt__source('kubernetes').with(
            location: 'https://pkgs.k8s.io/core:/stable:/v1.29/deb/',
            release: '/',
            repos: '',
            key: {
              'name'   => 'k8s.io.asc',
              'source' => 'https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key',
            },
          )
        end

        [
          [22,            'ssh',            'tcp'],
          [179,           'BGP',            'tcp'],
          [4789,          'VXLAN',          'udp'],
          [%w[2379 2380], 'etcd',           'tcp'],
          [10250,         'kubelet',        'tcp'],
          [6443,          'kubernetes API', 'tcp'],
          ['30000-32767', 'NodePorts',      'tcp'],
          [9100,          'Prometheus',     'tcp'],
        ].each do |ports, purpose, proto|
          it do
            is_expected.to contain_firewall("200 Cluster #{purpose}")
              .with_proto(proto)
              .with_dport(ports)
              .with_source('172.28.0.0/14')
              .with_state('NEW')
              .with_action('accept')
          end
        end
      end

      context 'with cluster set to second_cluster' do
        let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/second_cluster_config.yaml' }

        it { is_expected.to contain_package('kubelet').with_ensure('1.11.9-1.2') }
        it { is_expected.to contain_apt__pin('kubelet').with_version('1.11.9-1.2') }
        it { is_expected.to contain_firewall('200 Cluster BGP').with_source('10.123.234.0/24') }
      end
    end
  end
end
