# frozen_string_literal: true

# Copyright (c) 2018,2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'
require 'faker'

describe 'nebula::role::hathitrust::datasets' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:hiera_config) { 'spec/fixtures/hiera/hathitrust_config.yaml' }

      it { is_expected.to compile }

      it { is_expected.to contain_package('nfs-common') }
      it { is_expected.to contain_mount('/sdr1').with_options('auto,hard,nfsvers=3,ro') }
      it { is_expected.to contain_mount('/htprep') }

      describe 'unencrypted rsync' do
        it { is_expected.to contain_package('rsync') }
        it { is_expected.to contain_service('rsync').with_enable(true) }

        it { is_expected.to contain_firewall('200 rsync: dataset dataset1 - Test User 1, University of East Westtestland, testuser1@default.invalid').with_source('192.0.2.102') }
        it { is_expected.to contain_firewall('200 rsync: dataset dataset1 - Test User 2, University of West Easttestland, testuser2@default.invalid').with_source('198.51.100.10') }
        it { is_expected.to contain_firewall('200 rsync: dataset dataset2 - Test User 3, University of East Westtestland, testuser3@default.invalid').with_source('192.0.2.108') }
        it { is_expected.to contain_firewall('200 rsync: dataset dataset2 - Test User 4, University of West Easttestland, testuser4@default.invalid').with_source('198.51.100.15') }

        it { is_expected.to contain_file('/etc/rsyncd.conf').with_content(%r{path\s*=\s*/datasets/dataset1.*log file\s*=\s*/var/log/rsync/dataset1.log.*hosts allow =.*192.0.2.102.*198.51.100.10}m) }
        it { is_expected.to contain_file('/etc/rsyncd.conf').with_content(%r{/datasets/dataset2.*hosts allow =.*192.0.2.108.*198.51.100.15}m) }
      end

      describe 'encrypted rsync' do
        it { is_expected.to contain_package('stunnel4') }
        it { is_expected.to contain_service('secure-rsync').with_enable(true) }
        it { is_expected.to contain_file('/etc/systemd/system/secure-rsync.service').with_content(%r{ExecStart=/usr/bin/stunnel /etc/secure-rsync/stunnel.conf}) }
        it { is_expected.to contain_file('/etc/secure-rsync') }
        it { is_expected.to contain_file('/etc/secure-rsync/stunnel.conf').with_content(%r{rsync.*/etc/secure-rsync/rsyncd.conf.*CAfile=/etc/secure-rsync/client.crt}m) }
        it { is_expected.to contain_file('/etc/secure-rsync/rsyncd.conf').with_content(%r{/datasets/secure_dataset}m) }
        it { is_expected.to contain_file('/etc/secure-rsync/server.key') }
        it { is_expected.to contain_file('/etc/secure-rsync/server.crt') }
        it { is_expected.to contain_file('/etc/secure-rsync/client.crt') }

        it { is_expected.to contain_firewall('200 secure-rsync Net One').with_source('10.0.1.0/24') }
        it { is_expected.to contain_firewall('200 secure-rsync VPN').with_source('10.0.3.0/24') }
        it { is_expected.to contain_firewall('200 secure-rsync secure network').with_src_range('192.0.2.1-192.0.2.4') }
      end
    end
  end
end
