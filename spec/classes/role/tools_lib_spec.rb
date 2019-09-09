# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::role::tools_lib' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts.merge(disks: {}) }
      let(:hiera_config) { 'spec/fixtures/hiera/tools_lib_config.yaml' }

      it { is_expected.to compile }

      it { is_expected.to contain_package('fonts-dejavu-core') }
      it { is_expected.to contain_package('fontconfig') }
      it { is_expected.to contain_class('jira').with(version: '7.13.1') }
      it { is_expected.to contain_class('confluence').with(version: '6.14.1') }
      it { is_expected.to contain_class('nebula::profile::tools_lib::jira').with(mail_recipient: 'nobody@default.invalid') }
      it { is_expected.to contain_class('nebula::profile::tools_lib::confluence').with(mail_recipient: 'nobody@default.invalid') }
    end
  end
end
