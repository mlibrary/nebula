# frozen_string_literal: true

# Copyright (c) 2023 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::unattended_upgrades' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_class('apt') }
      it { is_expected.to contain_class('unattended_upgrades').with(only_on_ac_power: false) }
      it { is_expected.to contain_file('/etc/apt/apt.conf.d/51unattended-upgrades-extra') }
    end
  end
end
