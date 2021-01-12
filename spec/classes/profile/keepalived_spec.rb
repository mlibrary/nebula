# frozen_string_literal: true

# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

%w[primary backup].each do |role|
  describe "nebula::profile::keepalived::#{role}" do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:hiera_config) { 'spec/fixtures/hiera/keepalived/default_config.yaml' }

        if role == 'primary'
          let(:keepalived_state) { 'MASTER' }
          let(:keepalived_priority) { 101 }
        else
          let(:keepalived_state) { 'BACKUP' }
          let(:keepalived_priority) { 100 }
        end

        let(:relevant_facts) { {} }
        let(:facts) do
          os_facts.merge(
            datacenter: 'mydatacenter',
            networking: {
              interfaces: {
                eth0: {
                  network: '10.0.0.0',
                  netmask: '255.0.0.0',
                },
                eth1: {
                  network: '192.168.0.0',
                  netmask: '255.255.0.0',
                },
                :'eth1:0' => {
                  network: '192.168.99.0',
                  netmask: '255.255.255.0',
                },
                lo: {
                  network: '127.0.0.0',
                  netmask: '255.0.0.0',
                },
              },
            },
          ) do |key, old_value, new_value|
            if old_value.kind_of? Hash
              old_value.merge(new_value)
            else
              new_value
            end
          end.merge(relevant_facts) do |key, old_value, new_value|
            if old_value.kind_of? Hash
              old_value.merge(new_value)
            else
              new_value
            end
          end
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('keepalived') }

        context 'with nebula::scope set to mycompany' do
          let(:hiera_config) { 'spec/fixtures/hiera/keepalived/mycompany_config.yaml' }

          it do
            is_expected.to contain_keepalived__vrrp__instance('mydatacenter mycompany 10.1.2.3')
              .with_interface('eth0')
              .with_state(keepalived_state)
              .with_priority(keepalived_priority)
              .with_virtual_router_id(50)
              .with_virtual_ipaddress('10.1.2.3')
          end

          it do
            is_expected.to contain_keepalived__vrrp__instance('mydatacenter mycompany 192.168.1.2')
              .with_interface('eth1')
              .with_virtual_router_id(51)
              .with_virtual_ipaddress('192.168.1.2')
          end

          it do
            is_expected.to contain_keepalived__vrrp__instance('mydatacenter mycompany 192.168.99.1')
              .with_interface('eth1:0')
              .with_virtual_router_id(52)
              .with_virtual_ipaddress('192.168.99.1')
          end

          context 'and with datacenter set to abc' do
            let(:relevant_facts) { { datacenter: 'abc' } }

            it { is_expected.to contain_keepalived__vrrp__instance('abc mycompany 10.1.2.3') }
            it { is_expected.to contain_keepalived__vrrp__instance('abc mycompany 192.168.1.2') }
            it { is_expected.to contain_keepalived__vrrp__instance('abc mycompany 192.168.99.1') }
          end
        end

        context 'with nebula::scope set to ourcompany' do
          let(:hiera_config) { 'spec/fixtures/hiera/keepalived/ourcompany_config.yaml' }

          it do
            is_expected.to contain_keepalived__vrrp__instance('mydatacenter ourcompany 10.0.0.1')
              .with_interface('eth0')
              .with_virtual_router_id(50)
              .with_virtual_ipaddress('10.0.0.1')
          end

          it do
            is_expected.to contain_keepalived__vrrp__instance('mydatacenter ourcompany 192.168.50.1')
              .with_interface('eth1')
              .with_virtual_router_id(51)
              .with_virtual_ipaddress('192.168.50.1')
          end
        end
      end
    end
  end
end
