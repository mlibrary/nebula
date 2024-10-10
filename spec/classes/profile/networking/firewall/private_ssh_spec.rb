# frozen_string_literal: true

# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::networking::firewall::private_ssh' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      context 'with cidrs set to 10.0.0.0/8' do
        let(:params) { { cidrs: %w[10.0.0.0/8] } }

        it { is_expected.to compile }
        it { is_expected.to contain_firewall('100 Private SSH: 10.0.0.0/8').with_state('NEW') }
        it { is_expected.to contain_firewall('100 Private SSH: 10.0.0.0/8').with_action('accept') }
        it { is_expected.to contain_firewall('100 Private SSH: 10.0.0.0/8').with_proto('tcp') }
        it { is_expected.to contain_firewall('100 Private SSH: 10.0.0.0/8').with_dport(22) }
        it { is_expected.to contain_firewall('100 Private SSH: 10.0.0.0/8').with_source('10.0.0.0/8') }

        context 'with port set to 8080' do
          let(:params) { super().merge(port: 8080) }

          it { is_expected.to compile }
          it { is_expected.to contain_firewall('100 Private SSH: 10.0.0.0/8').with_dport(8080) }
        end
      end

      context 'with cidrs set to 172.16.0.0/12 and 192.168.0.0/16' do
        let(:params) { { cidrs: %w[172.16.0.0/12 192.168.0.0/16] } }

        it { is_expected.to compile }
        it { is_expected.to contain_firewall('100 Private SSH: 172.16.0.0/12').with_source('172.16.0.0/12') }
        it { is_expected.to contain_firewall('100 Private SSH: 192.168.0.0/16').with_source('192.168.0.0/16') }
      end
    end
  end
end
