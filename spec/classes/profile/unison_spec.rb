# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::unison' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:hiera_config) { 'spec/fixtures/hiera/unison_config.yaml' }

      context 'server' do
        let(:params) { { servers: %w[instance1 instance2] } }

        it { is_expected.to compile }

        # both instances are configured via hiera
        it do
          is_expected.to contain_nebula__unison__server('instance1').with(
            port: 2647,
            root: '/somewhere',
            paths: %w[something somethingelse],
            filesystems: ['somewhere'],
          )
        end

        it do
          is_expected.to contain_nebula__unison__server('instance2').with(
            port: 2648,
            root: '/elsewhere',
            paths: %w[otherthing yetanotherthing],
            filesystems: ['elsewhere'],
          )
        end
      end

      context 'client' do
        let(:params) { { clients: %w[instance1 instance2] } }

        it { is_expected.to compile }

        # can't test importing exported resources
      end
    end
  end
end
