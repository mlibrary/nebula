# frozen_string_literal: true

# Copyright (c) 2022, 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::bolt' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_package('puppet-bolt') }
      it { is_expected.to contain_file('/opt/bolt').with_ensure('directory') }
      it { is_expected.to contain_vcsrepo('/opt/bolt').with_ensure('latest') }
    end
  end
end
