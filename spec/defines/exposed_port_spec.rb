# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::exposed_port' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:hiera_config) { 'spec/fixtures/hiera/exposed_port_config.yaml' }

      context 'with title "100 SSH", port 22, and block "developers"' do
        let(:title) { '100 SSH' }
        let(:params) { { port: 22, block: 'developers' } }

        it { is_expected.to compile }

        it do
          is_expected.to contain_firewall('100 SSH: Developers').with(
            proto: 'tcp',
            dport: 22,
            source: '10.0.0.0/16',
            state: 'NEW',
            action: 'accept',
          )
        end

        context 'with protocol "udp"' do
          let(:params) do
            super().merge(protocol: 'udp')
          end

          it { is_expected.to contain_firewall('100 SSH: Developers').with_proto('udp') }
        end
      end

      context 'with title "200 HTTP", port 80, and block "users"' do
        let(:title) { '200 HTTP' }
        let(:params) { { port: 80, block: 'users' } }

        it { is_expected.to compile }

        it do
          is_expected.to contain_firewall('200 HTTP: VPN users').with(
            dport: 80,
            source: '10.10.10.0/24',
          )
        end

        it do
          is_expected.to contain_firewall('200 HTTP: On-site users')
            .with_source('10.10.11.0/24')
        end
      end

      context 'with block "devs_and_users"' do
        let(:title) { '250 HTTPS' }
        let(:params) { { port: 443, block: 'devs_and_users' } }

        it { is_expected.to compile }
        it { is_expected.to contain_firewall('250 HTTPS: Developers') }
        it { is_expected.to contain_firewall('250 HTTPS: VPN users') }
        it { is_expected.to contain_firewall('250 HTTPS: On-site users') }
      end

      context 'with title "400 Who knows" and block "developers"' do
        let(:title) { '400 Who knows' }
        let(:params) { { block: 'developers' } }

        context 'with port "30000-32967"' do
          let(:params) do
            super().merge(port: '30000-32967')
          end

          it do
            is_expected.to contain_firewall('400 Who knows: Developers')
              .with_dport('30000-32967')
          end
        end

        context 'with port [80, 443]' do
          let(:params) do
            super().merge(port: [80, 443])
          end

          it do
            is_expected.to contain_firewall('400 Who knows: Developers')
              .with_dport([80, 443])
          end
        end
      end
    end
  end
end
