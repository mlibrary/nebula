# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'
require 'faker'

describe 'nebula::profile::networking::firewall' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:hiera_config) { 'spec/fixtures/hiera/firewall_config.yaml' }

      it do
        is_expected.to contain_firewall('001 accept related established rules').with(
          proto: 'all',
          state: %w[RELATED ESTABLISHED],
          action: 'accept',
        )
      end

      it do
        is_expected.to contain_firewall('001 accept all to lo interface').with(
          proto: 'all',
          iniface: 'lo',
          action: 'accept',
        )
      end

      it do
        # from hiera
        is_expected.to contain_firewall('200 HTTP: custom rule').with(
          proto: 'tcp',
          dport: %w[8081 8082],
          source: '10.2.3.4',
          state: 'NEW',
          action: 'accept',
        )
      end

      it do
        is_expected.to contain_firewall('200 NTP: custom rule').with(
          proto: 'udp',
          dport: 123,
          source: '10.4.5.6',
          state: 'NEW',
          action: 'accept',
        )
      end

      it do
        is_expected.to contain_firewall('999 drop all').with(
          proto: 'all',
          action: 'drop',
        )
      end

      it { is_expected.to have_firewall_resource_count(5) }

      it { is_expected.to contain_package('iptables-persistent') }
      it { is_expected.to contain_package('netfilter-persistent') }
    end
  end
end
