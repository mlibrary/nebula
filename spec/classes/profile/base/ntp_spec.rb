# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::base::ntp' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it do
        is_expected.to contain_service('ntp').with(
          enable: true,
          ensure: 'running',
          require: ['Package[ntp]', 'Package[ntpstat]'],
        )
      end

      it { is_expected.to contain_package('ntp') }
      it { is_expected.to contain_package('ntpstat') }

      it do
        is_expected.to contain_file_line('no debian ntp servers').with(
          ensure: 'absent',
          path: '/etc/ntp.conf',
          match: '(server|pool).*debian.pool',
          match_for_absence: true,
          multiple: true,
          notify: 'Service[ntp]',
          require: ['Package[ntp]', 'Package[ntpstat]']
        )
      end

      it do
        is_expected.to contain_file_line('ntp server ntp.example.invalid').with(
          path: '/etc/ntp.conf',
          line: 'server ntp.example.invalid',
          after: '^#?server',
          notify: 'Service[ntp]',
          require: ['Package[ntp]', 'Package[ntpstat]']
        )
      end

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
          it do
            is_expected.to contain_file_line("ntp server #{server}")
              .with_line("server #{server}")
          end
        end
      end
    end
  end
end
