# frozen_string_literal: true

# Copyright (c) 2018-2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::puppet::db' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it do
        is_expected.to contain_class('puppetdb').with(
          disable_cleartext: true,
          manage_firewall: false,
          command_threads: nil,
          concurrent_writes: nil,
        )
      end

      context 'with command_threads set to 8' do
        let(:params) { { command_threads: 8 } }

        it { is_expected.to contain_class('puppetdb').with_command_threads(8) }
      end

      context 'with concurrent_writes set to 8' do
        let(:params) { { concurrent_writes: 8 } }

        it { is_expected.to contain_class('puppetdb').with_concurrent_writes(8) }
      end
    end
  end
end
