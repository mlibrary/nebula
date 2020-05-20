# frozen_string_literal: true

# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::kubernetes::router' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/first_cluster_config.yaml' }
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it do
        is_expected.to contain_file('/etc/sysctl.d/router.conf')
          .with_content(%r{^net\.ipv4\.ip_forward *= *1$})
          .that_notifies('Service[procps]')
      end

      it do
        is_expected.to contain_firewall('001 Do not NAT internal requests')
          .with_table('nat')
          .with_chain('POSTROUTING')
          .with_action('accept')
          .with_proto('all')
          .with_source('172.28.0.0/14')
          .with_destination('172.28.0.0/14')
      end

      it do
        is_expected.to contain_firewall('002 Give external requests our public IP')
          .with_table('nat')
          .with_chain('POSTROUTING')
          .with_jump('SNAT')
          .with_proto('all')
          .with_source('172.28.0.0/14')
          .with_tosource('10.0.0.1')
      end

      context 'with cluster set to second_cluster' do
        let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/second_cluster_config.yaml' }

        it do
          is_expected.to contain_firewall('001 Do not NAT internal requests')
            .with_source('10.123.234.0/24')
            .with_destination('10.123.234.0/24')
        end

        it do
          is_expected.to contain_firewall('002 Give external requests our public IP')
            .with_source('10.123.234.0/24')
            .with_tosource('10.0.0.2')
        end
      end
    end
  end
end
