# frozen_string_literal: true

# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::nat_router' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'when given no arguments' do
        it { is_expected.not_to compile }
      end

      context 'when given an ip address of 1.2.3.4 and a cidr of 10.0.0.0/8' do
        let(:params) { { ip_address: '1.2.3.4', cidr: '10.0.0.0/8' } }

        it { is_expected.to compile }

        it do
          is_expected.to contain_file('/etc/sysctl.d/nat_router.conf')
            .with_content("net.ipv4.ip_forward = 1\n")
            .that_notifies('Service[procps]')
        end

        it do
          is_expected.to contain_firewall('001 Do not NAT internal requests')
            .with_table('nat')
            .with_chain('POSTROUTING')
            .with_action('accept')
            .with_proto('all')
            .with_source('10.0.0.0/8')
            .with_destination('10.0.0.0/8')
        end

        it do
          is_expected.to contain_firewall('002 Give external requests our public IP address')
            .with_table('nat')
            .with_chain('POSTROUTING')
            .with_jump('SNAT')
            .with_proto('all')
            .with_source('10.0.0.0/8')
            .with_tosource('1.2.3.4')
        end
      end

      context 'when given an ip address of 2.4.6.8 and a cidr of 172.16.0.0/12' do
        let(:params) { { ip_address: '2.4.6.8', cidr: '172.16.0.0/12' } }

        it do
          is_expected.to contain_firewall('001 Do not NAT internal requests')
            .with_source('172.16.0.0/12')
            .with_destination('172.16.0.0/12')
        end

        it do
          is_expected.to contain_firewall('002 Give external requests our public IP address')
            .with_tosource('2.4.6.8')
        end
      end
    end
  end
end
