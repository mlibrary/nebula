# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::afs' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:kernelrelease) { os_facts[:kernelrelease] }

      today = Date.today.strftime('%Y-%m-%d')
      tomorrow = (Date.today + 1).strftime('%Y-%m-%d')

      it { is_expected.to contain_package('krb5-user') }
      it { is_expected.to contain_package('libpam-afs-session') }
      it { is_expected.to contain_package('libpam-krb5') }
      it { is_expected.to contain_package('openafs-client') }
      it { is_expected.to contain_package('openafs-krb5') }
      it { is_expected.to contain_package('openafs-modules-dkms') }

      it do
        is_expected.to contain_exec('reinstall kernel to enable afs').with(
          command: '/usr/bin/apt-get -y install --reinstall linux-headers-amd64',
          creates: "/lib/modules/#{kernelrelease}/updates/dkms/openafs.ko",
          timeout: 600,
          require: 'Package[openafs-modules-dkms]',
        )
      end

      it { is_expected.not_to contain_reboot('afs') }

      context "when allow_auto_reboot_until is #{today}" do
        let(:params) { { allow_auto_reboot_until: today } }

        it { is_expected.not_to contain_reboot('afs') }
      end

      context "when allow_auto_reboot_until is #{tomorrow}" do
        let(:params) { { allow_auto_reboot_until: tomorrow } }

        it do
          is_expected.to contain_reboot('afs')
            .that_subscribes_to('Exec[reinstall kernel to enable afs]')
            .with_apply('finished')
        end
      end

      it do
        is_expected.to contain_debconf('krb5-config/default_realm')
          .with_type('string')
          .with_value('REALM.DEFAULT.INVALID')
      end

      it do
        is_expected.to contain_debconf('openafs-client/thiscell')
          .with_type('string')
          .with_value('cell.default.invalid')
      end

      it do
        is_expected.to contain_debconf('openafs-client/cachesize')
          .with_type('string')
          .with_value('50000')
      end

      context 'given a realm of EXAMPLE.COM' do
        let(:params) { { realm: 'EXAMPLE.COM' } }

        it do
          is_expected.to contain_debconf('krb5-config/default_realm')
            .with_type('string')
            .with_value('EXAMPLE.COM')
        end
      end

      context 'given a cell of example.com' do
        let(:params) { { cell: 'example.com' } }

        it do
          is_expected.to contain_debconf('openafs-client/thiscell')
            .with_type('string')
            .with_value('example.com')
        end
      end

      context 'given a cache_size of 100' do
        let(:params) { { cache_size: 100 } }

        it do
          is_expected.to contain_debconf('openafs-client/cachesize')
            .with_type('string')
            .with_value('100')
        end
      end

      %w[login profile].each do |suffix|
        it do
          is_expected.to contain_file("/usr/local/skel/sys.#{suffix}")
            .with_source('puppet:///modules/nebula/skel.txt')
            .that_requires('File[/usr/local/skel]')
        end
      end

      it do
        is_expected.to contain_file('/usr/local/skel').with(
          ensure: 'directory',
          mode: '0755',
        )
      end
    end
  end
end
