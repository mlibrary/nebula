# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::work_around_puppet_bugs' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:state_yaml) { '/opt/puppetlabs/puppet/cache/state/state.yaml' }

      it { is_expected.to contain_tidy(state_yaml).with_size('10m') }

      context 'when given a state_yaml_path' do
        let(:state_yaml) { "/var/lib/#{Faker::Internet.domain_word}/state.yaml" }
        let(:params) { { state_yaml_path: state_yaml } }

        it { is_expected.to contain_tidy(state_yaml).with_size('10m') }
      end

      context 'when given a state_yaml_max_size of 500k' do
        let(:params) { { state_yaml_max_size: '500k' } }

        it { is_expected.to contain_tidy(state_yaml).with_size('500k') }
      end
    end
  end
end
