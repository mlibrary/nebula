# frozen_string_literal: true

# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::github_pull_account' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_user('git').with_home('/var/lib/autogit') }
      it { is_expected.to contain_user('git').with_gid(100) }
      it { is_expected.to contain_user('git').with_managehome(true) }
      it { is_expected.to contain_file('/var/lib/autogit/.ssh').with_ensure('directory') }
      it { is_expected.to contain_file('/var/lib/autogit/.ssh').with_mode('0700') }
      it { is_expected.to contain_exec('create /var/lib/autogit/.ssh/id_ecdsa') }
      it { is_expected.to contain_exec('create /var/local/github_ssh_keys') }
      it { is_expected.to contain_concat_fragment('github ssh keys').with_target('/etc/ssh/ssh_known_hosts') }
    end
  end
end
