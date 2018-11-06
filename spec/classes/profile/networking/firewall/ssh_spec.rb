# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::networking::firewall::ssh' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it { is_expected.to have_firewall_resource_count(0) }

      context 'with a CIDR range' do
        let(:params) { { blocks: [{ 'name' => 'test range', 'source' => '10.1.2.0/24' }] } }

        it { is_expected.to contain_firewall('100 SSH: test range').with_source('10.1.2.0/24') }
      end
    end
  end
end
