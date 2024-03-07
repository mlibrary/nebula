# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::firewall_allow' do
  let(:title) { 'my_firewall_allow' }
  let(:params) { {} }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:hiera_config) { 'spec/fixtures/hiera/firewall_allow_config.yaml' }

      context 'when given "lowest" and 1234' do
        let(:params) { { source: 'lowest', port: 1234 } }

        it do
          is_expected.to contain_firewall("300 #{title} 0").with(
            proto: 'tcp',
            dport: 1234,
            source: '10.0.0.0/32',
            state: 'NEW',
            jump: 'accept',
          )
        end

        context 'and the title is set to "Cool Firewall"' do
          let(:title) { 'Cool Firewall' }

          it { is_expected.to contain_firewall('300 Cool Firewall 0') }
        end

        context 'and order is set to 500' do
          let(:params) do
            super().merge(order: 500)
          end

          it { is_expected.to contain_firewall("500 #{title} 0") }
        end

        context 'and proto is set to "udp"' do
          let(:params) do
            super().merge(proto: 'udp')
          end

          it { is_expected.to contain_firewall("300 #{title} 0").with_proto('udp') }
        end
      end

      context 'when given "highest" and [123, 456, 789]' do
        let(:params) { { source: 'highest', port: [123, 456, 789] } }

        it do
          is_expected.to contain_firewall("300 #{title} 0").with(
            proto: 'tcp',
            dport: [123, 456, 789],
            source: '10.255.255.255/32',
            state: 'NEW',
            jump: 'accept',
          )
        end
      end

      context 'when given "low_three"' do
        let(:params) { { source: 'low_three', port: 246 } }

        it { is_expected.to contain_firewall("300 #{title} 0").with_source('10.0.1.0/24') }
        it { is_expected.to contain_firewall("300 #{title} 1").with_source('10.0.2.0/24') }
        it { is_expected.to contain_firewall("300 #{title} 2").with_source('10.0.3.0/24') }
      end

      context 'when given "all"' do
        let(:params) { { source: 'all', port: 369 } }

        it { is_expected.to contain_firewall("300 #{title} 0").with_source('10.0.0.0/32') }
        it { is_expected.to contain_firewall("300 #{title} 1").with_source('10.255.255.255/32') }
        it { is_expected.to contain_firewall("300 #{title} 2").with_source('10.0.1.0/24') }
        it { is_expected.to contain_firewall("300 #{title} 3").with_source('10.0.2.0/24') }
        it { is_expected.to contain_firewall("300 #{title} 4").with_source('10.0.3.0/24') }
      end

      context 'when given ["lowest", "highest"]' do
        let(:params) { { source: %w[lowest highest], port: 321 } }

        it { is_expected.to contain_firewall("300 #{title} 0").with_source('10.0.0.0/32') }
        it { is_expected.to contain_firewall("300 #{title} 1").with_source('10.255.255.255/32') }
      end
    end
  end
end
