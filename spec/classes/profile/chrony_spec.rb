# frozen_string_literal: true

# Copyright (c) 2018-2023 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::chrony' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it do
        is_expected.to contain_service('chrony').with(
          enable: true,
          ensure: 'running',
        )
      end

      it { is_expected.to contain_package('chrony') }

      it { is_expected.to contain_file('/etc/chrony/sources.d/local-ntp-server.sources').with_content(%r{^server ntp.example.invalid$}m) }

      it { is_expected.to contain_file('/etc/chrony/sources.d/local-ntp-server.sources').that_notifies('Service[chrony]') }

      context 'given ntp[123].realdomain.com' do
        let(:params) do
          {
            servers: [
              'ntp1.realdomain.com',
              'ntp2.realdomain.com',
              'ntp3.realdomain.com',
            ],
          }
        end

        [
          'ntp1.realdomain.com',
          'ntp2.realdomain.com',
          'ntp3.realdomain.com',
        ].each do |server|
          it { is_expected.to contain_file('/etc/chrony/sources.d/local-ntp-server.sources').with_content(%r{^server #{server}$}m) }
        end
      end

      context 'on a kvm vm' do
        let(:facts) { super().merge(is_virtual: true, virtual: 'kvm') }

        it { is_expected.to contain_file('/etc/chrony/conf.d/kvm.conf') }
        it { is_expected.to contain_kmod__load('ptp_kvm') }
      end
    end
  end
end
