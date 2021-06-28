# frozen_string_literal: true

# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::falcon' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with cid set to mycid' do
        let(:params) { { cid: 'mycid' } }

        it { is_expected.to compile }
        it { is_expected.to contain_package('falcon-sensor') }
        it { is_expected.to contain_service('falcon-sensor').with_ensure('running') }

        it do
          is_expected.to contain_exec('set falcon-sensor CID')
            .with_command("/opt/CrowdStrike/falconctl -s '--cid=mycid'")
            .with_unless('/opt/CrowdStrike/falconctl -g --cid')
            .that_requires('Package[falcon-sensor]')
            .that_notifies('Service[falcon-sensor]')
        end
      end

      context 'with cid set to somethingelse' do
        let(:params) { { cid: 'somethingelse' } }

        it do
          is_expected.to contain_exec('set falcon-sensor CID')
            .with_command("/opt/CrowdStrike/falconctl -s '--cid=somethingelse'")
        end
      end
    end
  end
end
