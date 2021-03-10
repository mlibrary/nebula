# frozen_string_literal: true

# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::scales' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it { is_expected.to contain_nebula__usergroup('clearinghouse') }

      it do
        is_expected.to contain_nebula__exposed_port('100 SSH Umich VPN').with(
          port: 22,
          block: 'umich::networks::umich_vpn',
        )
      end
    end
  end
end
