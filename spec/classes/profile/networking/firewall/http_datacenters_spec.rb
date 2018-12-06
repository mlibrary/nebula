# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'
require_relative '../../../../support/contexts/with_mocked_nodes'

describe 'nebula::profile::networking::firewall::http_datacenters' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      include_context 'with mocked query for nodes in other datacenters'

      it { is_expected.to compile }

      it { is_expected.to have_firewall_resource_count(0) }

      context 'with a CIDR range' do
        include_context 'with mocked query for nodes in other datacenters', ['somedc'], []

        let(:params) { { networks: [{ 'name' => 'somedc', 'block' => '10.1.2.0/24', 'datacenter' => 'somedc' }] } }

        it { is_expected.to contain_firewall('200 HTTP: somedc').with_source('10.1.2.0/24') }
      end

      context 'with deeply-nested ranges and nodes in other datacenters' do
        othernodes = { 'node1' => '10.3.4.5', 'node2' => '10.4.5.6' }

        include_context 'with mocked query for nodes in other datacenters', %w[dc1 dc2], othernodes

        let(:params) do
          {
            networks: [
              [
                { 'name' => 'test range 1-1', 'block' => '10.1.1.0/24', 'datacenter' => 'dc1' },
                { 'name' => 'test range 1-2', 'block' => '10.1.2.0/24', 'datacenter' => 'dc2' },
              ],
              [
                { 'name' => 'test range 2-1', 'block' => '10.2.1.0/24', 'datacenter' => 'dc2' },
                { 'name' => 'test range 2-2', 'block' => '10.2.2.0/24', 'datacenter' => 'dc2' },
              ],
            ],
          }
        end

        it { is_expected.to contain_firewall('200 HTTP: test range 1-1').with_source('10.1.1.0/24').with_dport([80, 443]) }
        it { is_expected.to contain_firewall('200 HTTP: test range 1-2').with_source('10.1.2.0/24').with_dport([80, 443]) }
        it { is_expected.to contain_firewall('200 HTTP: test range 2-1').with_source('10.2.1.0/24').with_dport([80, 443]) }
        it { is_expected.to contain_firewall('200 HTTP: test range 2-2').with_source('10.2.2.0/24').with_dport([80, 443]) }

        othernodes.each do |name, ip|
          it { is_expected.to contain_firewall("200 HTTP: #{name}").with_source(ip).with_dport([80, 443]) }
        end
      end
    end
  end
end
