# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::base::firewall::ipv4' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to contain_package('iptables-persistent') }

      it do
        is_expected.to contain_service('netfilter-persistent')
          .that_requires('Package[iptables-persistent]')
      end

      it do
        is_expected.to contain_nebula__file__firewall('/etc/firewall.ipv4')
          .that_requires('Package[iptables-persistent]')
          .that_notifies('Service[netfilter-persistent]')
          .with_rules(
            [
              '-A INPUT -p tcp -s 1.2.3.4 -j ACCEPT',
              '-A INPUT -p tcp -s 5.6.7.8 -j ACCEPT',
            ],
          )
      end

      context 'when called with some rules' do
        let(:params) do
          {
            rules: [
              '-A INPUT -p tcp -m tcp -s 4.3.2.1 -j ACCEPT',
              '-A INPUT -p tcp -m tcp -s 8.7.6.5 -j ACCEPT',
            ],
          }
        end

        it do
          is_expected.to contain_nebula__file__firewall('/etc/firewall.ipv4')
            .with_rules(
              [
                '-A INPUT -p tcp -m tcp -s 4.3.2.1 -j ACCEPT',
                '-A INPUT -p tcp -m tcp -s 8.7.6.5 -j ACCEPT',
              ],
            )
        end
      end

      context 'when called with a filename of /opt/firewall' do
        let(:params) { { filename: '/opt/firewall' } }

        it { is_expected.to contain_nebula__file__firewall('/opt/firewall') }
      end
    end
  end
end
