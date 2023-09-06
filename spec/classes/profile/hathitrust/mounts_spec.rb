
# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::hathitrust::mounts' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts.merge(networking: { ip: Faker::Internet.ip_v4_address, interfaces: {} }) }
      let(:hiera_config) { 'spec/fixtures/hiera/hathitrust_config.yaml' }

      it { is_expected.to contain_package('nfs-common') }
      it { is_expected.to contain_mount('/sdr1').with_options('auto,hard,nfsvers=3,ro') }
      it { is_expected.to contain_nebula__nfs_mount('/sdr1') }

      it { is_expected.to contain_mount('/htapps').that_requires('File[/etc/resolv.conf]') }
      it { is_expected.to contain_mount('/htapps').that_requires('Service[bind9]') }
      it { is_expected.to contain_nebula__nfs_mount('/htapps') }

      it { is_expected.to contain_file('/etc/resolv.conf').with_content(%r{nameserver 127.0.0.1}) }
      it { is_expected.to contain_service('bind9') }

      context 'with /htapps specified as a non-smartconnect mount' do
        let(:params) do
          {
            smartconnect_mounts: [],
            other_nfs_mounts: {
              '/htapps' => { 'remote_target' => 'somehost:/htapps' },
            },
          }
        end

        it do
          is_expected.to contain_mount('/htapps').with(
            device: 'somehost:/htapps',
            fstype: 'nfs',
          )
        end
      end
    end
  end
end
