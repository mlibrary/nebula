# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::groups' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:hiera_config) { 'spec/fixtures/hiera/usergroups_config.yaml' }
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it { is_expected.to contain_group('examplegroup1').with_gid(1234) }
      it { is_expected.to contain_group('examplegroup2').with_gid(2468) }

      context 'when given different_group with a gid of 2358' do
        let(:params) { { all_groups: { 'different_group' => 2358 } } }

        it { is_expected.not_to contain_group('examplegroup1') }
        it { is_expected.to contain_group('different_group').with_gid(2358) }
      end
    end
  end
end
