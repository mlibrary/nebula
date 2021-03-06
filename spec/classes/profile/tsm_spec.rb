# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::tsm' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:dsm_sys) { '/opt/tivoli/tsm/client/ba/bin/dsm.sys' }
      let(:dsm_opt) { '/opt/tivoli/tsm/client/ba/bin/dsm.opt' }
      let(:inclexcl) { '/etc/adsm/inclexcl' }

      let(:params) do
        {
          servername: 'tsmserver1',
          serveraddress: 'tsmserver1.example.invalid',
        }
      end

      it { is_expected.to contain_package('tivsm-ba') }

      it do
        is_expected.to contain_file(dsm_sys)
          .with_content(%r{Servername\s+tsmserver1$}i)
          .with_content(%r{VIRTUALMOUNTPOINT /etc})
          .with_content(%r{EXCLUDE.DIR "/afs/"})
          .with_content(%r{TCPServeraddress\s+tsmserver1.example.invalid}i)
          .with_content(%r{TCPPort\s+1510}i)
          .without_content(%r{encrypt})
      end

      it do
        is_expected.to contain_file(dsm_opt)
          .with_content(%r{DOMAIN "/etc"})
          .with_content(%r{\* No custom settings})
      end

      it { is_expected.to contain_service('tsm') }

      it do
        is_expected.to contain_service('dsmcad')
          .with_ensure('stopped')
          .with_enable(false)
      end

      it { is_expected.to contain_file('/etc/systemd/system/tsm.service') }

      it { is_expected.to contain_file(inclexcl) }

      context 'with custom params' do
        let(:params) do
          super().merge(
            servername: 'otherserver',
            serveraddress: 'somethingelse.default.invalid',
            encryption: true,
            port: 1234,
            inclexcl: ['exclude.dir /foo', 'include /bar otherpolicy'],
            domains: ['/baz', '/quux'],
            virtualmountpoints: ['/vmount'],
            exclude_dirs: ['/whatever'],
            opt_settings: [
              'first_setting first_value',
              'second_setting "second_value"',
            ],
          )
        end

        it 'adds domain settings to dsm.opt config file' do
          is_expected.to contain_file(dsm_opt)
            .with_content(%r{^DOMAIN "/baz"$})
            .with_content(%r{^DOMAIN "/quux"$})
        end

        it 'adds custom settings to dsm.opt config file' do
          is_expected.to contain_file(dsm_opt)
            .with_content(%r{^first_setting first_value$})
            .with_content(%r{^second_setting "second_value"$})
        end

        it 'adds custom settings to dsm.sys config file' do
          is_expected.to contain_file(dsm_sys)
            .with_content(%r{^Servername otherserver}i)
            .with_content(%r{VIRTUALMOUNTPOINT /vmount})
            .with_content(%r{encryptiontype})
            .with_content(%r{TCPPort\s*1234})
            .with_content(%r{TCPServeraddress\s*somethingelse.default.invalid})
            .with_content(%r{EXCLUDE.DIR "/whatever"})
        end

        it 'adds custom settings to inclexcl config file' do
          is_expected.to contain_file(inclexcl)
            .with_content(%r{^exclude.dir /foo$})
            .with_content(%r{^include /bar otherpolicy$})
        end
      end
    end
  end
end
