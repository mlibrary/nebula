# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::role::vmhost' do
  def contain_sysctl
    contain_class('nebula::profile::networking::sysctl')
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      unless os == 'debian-8-x86_64'
        it { is_expected.to contain_sysctl.with_bridge(true) }
      end

      it { is_expected.not_to contain_class('nebula::profile::afs') }
      it { is_expected.not_to contain_class('nebula::profile::users') }
    end
  end
end
