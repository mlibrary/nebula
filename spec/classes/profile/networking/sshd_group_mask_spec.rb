# frozen_string_literal: true

# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::networking::sshd_group_umask' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it do
        is_expected.to contain_concat_fragment('/etc/pam.d/sshd: group umask')
          .with_target('/etc/pam.d/sshd')
          .with_content(%r{session    optional   pam_umask.so umask=0002})
      end
    end
  end
end
