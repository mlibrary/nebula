# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'
require_relative '../../support/contexts/with_mocked_nodes'

describe 'nebula::role::load_balancer' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:my_ip) { Faker::Internet.ip_v4_address }

      let(:facts) do
        os_facts.merge(
          datacenter: 'somedc',
          networking: {
            ip: my_ip,
            primary: 'eth0',
          },
          hostname: 'thisnode',
        )
      end

      let(:default_file) { '/etc/default/haproxy' }
      let(:haproxy_conf) { '/etc/haproxy/haproxy.cfg' }
      let(:keepalived_conf) { '/etc/keepalived/keepalived.conf' }
      let(:service) { 'keepalived' }

      let(:thisnode) { { 'ip' => facts[:networking][:ip], 'hostname' => facts[:hostname] } }
      let(:haproxy2) { { 'ip' => Faker::Internet.ip_v4_address, 'hostname' => 'haproxy2' } }
      let(:scotch) { { 'ip' => '111.111.111.123', 'hostname' => 'scotch' } }
      let(:soda)   { { 'ip' => '222.222.222.234', 'hostname' => 'soda' } }
      let(:third_server) { { 'ip' => '333.333.333.345', 'hostname' => 'third_server' } }

      include_context 'with mocked puppetdb functions', 'somedc', %w[thisnode haproxy2 scotch soda third_server], 'nebula::profile::haproxy' => %w[thisnode haproxy2]

      before(:each) do
        stub('balanced_frontends') do |d|
          allow_call(d).and_return('svc1' => %w[scotch soda], 'svc2' => %w[scotch third_server])
        end
      end

      it { is_expected.to compile }
    end
  end
end
