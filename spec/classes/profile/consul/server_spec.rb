# frozen_string_literal: true

# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::consul::server' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_class('Nebula::Profile::Consul::Client') }

      [[8600,          'tcp', 'DNS (tcp)'],
       [8600,          'udp', 'DNS (udp)'],
       [8500,          'tcp', 'HTTP API'],
       [8302,          'tcp', 'gRPC API'],
       [8301,          'tcp', 'LAN Serf (tcp)'],
       [8301,          'udp', 'LAN Serf (udp)'],
       [8300,          'tcp', 'Server RPC'],
       ['21000-21255', 'tcp', 'Sidecar Proxy']].each do |port, protocol, service|
        it do
          is_expected.to contain_nebula__exposed_port("020 Consul #{service}")
            .with_block('umich::networks::private_lan')
            .with_port(port)
            .with_protocol(protocol)
        end
      end
    end
  end
end
