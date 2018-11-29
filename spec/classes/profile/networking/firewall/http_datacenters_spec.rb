# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::networking::firewall::http_datacenters' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it { is_expected.to have_firewall_resource_count(0) }

      context 'with a CIDR range' do
        let(:params) { { blocks: [{ 'name' => 'somedc', 'source' => '10.1.2.0/24' }] } }

        it { is_expected.to contain_firewall('200 HTTP: somedc').with_source('10.1.2.0/24') }
      end

      context 'with deeply-nested ranges' do
        let(:params) do
          {
            blocks: [
              [
                { 'name' => 'test range 1-1', 'source' => '10.1.1.0/24' },
                { 'name' => 'test range 1-2', 'source' => '10.1.2.0/24' },
              ],
              [
                { 'name' => 'test range 2-1', 'source' => '10.2.1.0/24' },
                { 'name' => 'test range 2-2', 'source' => '10.2.2.0/24' },
              ],
            ],
          }
        end

        it { is_expected.to contain_firewall('200 HTTP: test range 1-1').with_source('10.1.1.0/24') }
        it { is_expected.to contain_firewall('200 HTTP: test range 1-2').with_source('10.1.2.0/24') }
        it { is_expected.to contain_firewall('200 HTTP: test range 2-1').with_source('10.2.1.0/24') }
        it { is_expected.to contain_firewall('200 HTTP: test range 2-2').with_source('10.2.2.0/24') }
      end
    end
  end
end
