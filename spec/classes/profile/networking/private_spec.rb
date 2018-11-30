# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::networking::private' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge(networking: { ip: '1.2.3.123' })
      end

      context 'with fully-specified parameters' do
        let(:params) do
          {
            address_template: '10.0.2.%s',
            netmask: '255.255.0.0',
            network: '10.0.0.0',
            broadcast: '10.0.255.255',
            interface: 'eth1',
          }
        end

        it do
          is_expected.to contain_file('/etc/network/interfaces.d/private').with_content(<<~EOT)
            auto eth1
            iface eth1 inet static
              address 10.0.2.123
              netmask 255.255.0.0
              network 10.0.0.0
              broadcast 10.0.255.255
          EOT
        end
      end

      context 'with no interface' do
        it { is_expected.not_to contain_file('/etc/network/interfaces.d/private') }
      end

      if os == 'debian-9-x86_64'
        context 'with ens4' do
          let(:facts) do
            os_facts.merge(
              networking: {
                ip: '1.2.3.123',
                interfaces: { 'ens4' => {} },
              },
              is_virtual: true,
            )
          end

          it do
            is_expected.to contain_file('/etc/network/interfaces.d/private')
              .with_content(%r{auto ens4\niface ens4 inet static}m)
          end
        end
      end
    end
  end
end
