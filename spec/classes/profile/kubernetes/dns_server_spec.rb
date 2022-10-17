# frozen_string_literal: true

# Copyright (c) 2020, 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::kubernetes::dns_server' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      context 'with cluster set to first_cluster' do
        let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/first_cluster_config.yaml' }
        let(:facts) do
          os_facts.merge(
            'networking'   => {
              'interfaces' => {
                'ens4'     => {
                  'ip'     => '10.123.234.5',
                },
              },
            },
          )
        end

        it { is_expected.to compile }

        it { is_expected.to contain_package('dnsmasq') }
        it { is_expected.to contain_service('dnsmasq').that_requires('Package[dnsmasq]') }

        it { is_expected.to contain_firewall('200 Nameserver (TCP)').with_proto('tcp') }
        it { is_expected.to contain_firewall('200 Nameserver (UDP)').with_proto('udp') }

        %w[TCP UDP].each do |proto|
          it do
            is_expected.to contain_firewall("200 Nameserver (#{proto})")
              .with_dport(53)
              .with_source('172.28.0.0/14')
              .with_state('NEW')
              .with_action('accept')
          end
        end

        it { is_expected.to contain_concat('/etc/hosts').that_notifies('Service[dnsmasq]') }

        it do
          is_expected.to contain_concat_fragment('/etc/hosts ipv4 localhost')
            .with_target('/etc/hosts')
            .with_order('01')
            .with_content("127.0.0.1 localhost\n")
        end

        it do
          is_expected.to contain_concat_fragment('/etc/hosts ipv4 etcd-all')
            .with_target('/etc/hosts')
            .with_order('02')
            .with_content("172.16.0.6 etcd.first.cluster etcd\n")
        end

        it do
          is_expected.to contain_concat_fragment('/etc/hosts ipv4 kube-api')
            .with_target('/etc/hosts')
            .with_order('03')
            .with_content("172.16.0.7 kube-api.first.cluster kube-api\n")
        end

        it do
          is_expected.to contain_concat_fragment('/etc/hosts ipv6 localhost')
            .with_target('/etc/hosts')
            .with_order('05')
            .with_content("::1 localhost ip6-localhost ip6-loopback\n")
        end

        it do
          is_expected.to contain_file('/etc/dnsmasq.d/smartconnect')
            .with_content("server=/sc.default.invalid/192.0.2.7\n")
        end

        it do
          is_expected.to contain_concat_fragment('/etc/hosts ipv6 debian')
            .with_target('/etc/hosts')
            .with_order('06')
            .with_content("ff02::1 ip6-allnodes\nff02::2 ip6-allrouters\n")
        end
      end

      context 'with cluster set to second_cluster' do
        let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/second_cluster_config.yaml' }
        let(:facts) { os_facts }

        it { is_expected.to compile }

        it { is_expected.not_to contain_file('/etc/dnsmasq.d/smartconnect') }
      end
    end
  end
end
