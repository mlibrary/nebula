# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'
require 'faker'
require_relative '../../support/contexts/with_mocked_nodes'

describe 'nebula::role::deb_server' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      include_context 'with mocked query for nodes in other datacenters'

      let(:facts) { os_facts.merge(networking: { ip: Faker::Internet.ip_v4_address, interfaces: {} }) }
      let(:hiera_config) { 'spec/fixtures/hiera/deb_server_config.yaml' }

      it { is_expected.to compile }
      it { is_expected.not_to contain_file('/etc/firewall.ipv4') }

      case os
      when 'debian-8-x86_64'
        it { is_expected.not_to contain_class('nebula::profile::base::firewall::ipv4') }
        it { is_expected.to have_firewall_resource_count(0) }
      when 'debian-9-x86_64'
        it { is_expected.to contain_class('nebula::profile::networking::firewall') }
      end
    end
  end
end
