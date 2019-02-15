# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::ntp' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it do
        is_expected.to contain_service('ntp').with(
          enable: true,
          ensure: 'running',
        )
      end

      it { is_expected.to contain_package('ntp') }
      it { is_expected.to contain_package('ntpstat') }

      it { is_expected.to contain_file('/etc/ntp.conf').with_content(%r{^server ntp.example.invalid$}m) }

      it { is_expected.to contain_file('/etc/ntp.conf').that_notifies('Service[ntp]') }

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
          it { is_expected.to contain_file('/etc/ntp.conf').with_content(%r{^server #{server}$}m) }
        end
      end
    end
  end
end
