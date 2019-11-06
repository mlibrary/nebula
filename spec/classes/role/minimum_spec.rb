# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::role::minimum' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      case os
      when 'debian-8-x86_64'
        it { is_expected.not_to contain_class('nebula::profile::networking::firewall') }
        it { is_expected.to have_firewall_resource_count(0) }
      when 'debian-9-x86_64'
        it { is_expected.to contain_class('nebula::profile::networking::firewall') }
      end
    end
  end
end
