# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'
require 'faker'
# require_relative '../../support/contexts/with_mocked_nodes'

describe 'nebula::role::deb_server' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts.merge(networking: { ip: Faker::Internet.ip_v4_address, interfaces: {} }) }
      let(:hiera_config) { 'spec/fixtures/hiera/deb_server_config.yaml' }

      it { is_expected.to compile }
    end
  end
end
