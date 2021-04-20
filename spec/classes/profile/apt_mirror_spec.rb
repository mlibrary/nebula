# frozen_string_literal: true

# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::apt_mirror' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it { is_expected.to contain_package('debmirror') }
      it { is_expected.to contain_package('s3fs') }
      it { is_expected.to contain_package('debian-keyring') }

      it do
        is_expected.to contain_group('apt-mirror')
          .with_system('true')
          .with_gid('996')
      end

      it do
        is_expected.to contain_user('apt mirror user')
          .with_name('apt-mirror')
          .with_groups(['apt-mirror'])
          .with_gid('996')
          .with_uid('996')
          .with_system('true')
          .with_password('!')
          .with_home('/var/local/apt-mirror')
          .with_managehome('true')
          .with_shell('/bin/false')
      end

      it do
        is_expected.to contain_file('/usr/local/bin/apt-mirror-sync.sh')
          .with_mode('0770')
          .with_owner('apt-mirror')
          .with_group('apt-mirror')
          .with_path('/usr/local/bin/apt-mirror-sync.sh')
      end

      it do
        is_expected.to contain_cron('apt mirror sync using debmirror')
          .with_user('apt-mirror')
          .with_command('/usr/local/bin/apt-mirror-sync.sh')
      end
    end
  end
end
