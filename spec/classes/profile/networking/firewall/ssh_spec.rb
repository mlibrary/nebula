# frozen_string_literal: true

# Copyright (c) 2018-2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::networking::firewall::ssh' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'when publicly accessible' do
        let(:facts) do
          super().merge(
            'networking' => {
              'interfaces' => { 'eth0' => { 'ip' => '123.45.67.89' } },
            },
          )
        end

        it { is_expected.to compile }

        it do
          is_expected.to contain_nebula__exposed_port('100 SSH').with(
            port: 22,
            block: 'umich::networks::all_trusted_machines',
          )
        end
      end

      context 'when publicly inaccessible' do
        let(:facts) do
          super().merge(
            'networking' => {
              'interfaces' => { 'eth0' => { 'ip' => '10.45.67.89' } },
            },
          )
        end

        it { is_expected.to compile }

        it do
          is_expected.to contain_nebula__exposed_port('100 SSH').with(
            port: 22,
            block: 'umich::networks::private_bastion_hosts',
          )
        end
      end
    end
  end
end
