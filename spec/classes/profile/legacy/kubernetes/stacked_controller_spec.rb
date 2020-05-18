# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::legacy::kubernetes::stacked_controller' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:hiera_config) { 'spec/fixtures/hiera/kubernetes_config.yaml' }
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_class('Nebula::Profile::Legacy::Kubernetes') }

      it do
        is_expected.to contain_concat_file('kubeadm config').with(
          path: '/etc/kubeadm_config.yaml',
          format: 'yaml',
        )
      end

      [
        ['apiVersion', 'kubeadm.k8s.io/v1beta1'],
        %w[kind ClusterConfiguration],
        ['kubernetesVersion', '1.14.2'],
        ['controlPlaneEndpoint', 'first_cluster.default.invalid:6443'],
      ].each do |key, value|
        it do
          is_expected.to contain_concat_fragment("kubeadm config #{key}").with(
            target: 'kubeadm config',
            content: "#{key}: '#{value}'",
          )
        end
      end

      [
        ['serviceSubnet', '172.16.0.0/13'],
        ['podSubnet', '172.24.0.0/14'],
      ].each do |key, value|
        it do
          is_expected.to contain_concat_fragment("kubeadm config networking.#{key}").with(
            target: 'kubeadm config',
            content: "networking: {#{key}: '#{value}'}",
          )
        end
      end

      describe 'exported resources' do
        subject { exported_resources }

        [
          ['etcd', [2379, 2380]],
        ].each do |purpose, port|
          it do
            is_expected.to contain_firewall("200 first_cluster #{purpose} #{facts[:fqdn]}").with(
              proto: 'tcp',
              dport: port,
              source: facts[:ipaddress],
              state: 'NEW',
              action: 'accept',
              tag: "first_cluster_#{purpose}",
            )
          end
        end

        it do
          is_expected.to contain_concat_fragment("haproxy kubectl #{facts[:hostname]}")
            .with_target('/etc/haproxy/haproxy.cfg')
            .with_order('02')
            .with_content("  server #{facts[:hostname]} #{facts[:ipaddress]}:6443 check\n")
            .with_tag('first_cluster_haproxy_kubectl')
        end

        it do
          is_expected.to contain_concat_fragment("haproxy ip #{os_facts[:hostname]}")
            .with_target('/etc/kubernetes_addresses.yaml')
            .with_content("addresses: {control: {#{os_facts[:hostname]}: '#{os_facts[:ipaddress]}'}}")
            .with_tag('first_cluster_proxy_ips')
        end
      end
    end
  end
end
