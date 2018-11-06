# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'
require_relative '../../../../support/contexts/with_mocked_nodes'

describe 'nebula::profile::networking::firewall::http' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      let(:haproxy) { { 'ip' => '10.255.2.3', 'hostname' => 'haproxy' } }
      let(:rolenode) { { 'ip' => '10.255.3.4', 'hostname' => 'rolenode' } }

      include_context 'with mocked puppetdb functions', 'somedc', %w[haproxy rolenode], {'nebula::profile::haproxy' => %w[haproxy]}

      it { is_expected.to contain_firewall('200 HTTP: HAProxy haproxy').with_source(haproxy["ip"]) }

    end
  end
end
