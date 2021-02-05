# frozen_string_literal: true

# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::consul::client' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it do
        is_expected.to contain_apt__source('hashicorp')
          .with_location('https://apt.releases.hashicorp.com')
          .with_release(facts[:os]['distro']['codename'])
          .with_repos('main')
      end

      it do
        is_expected.to contain_package('consul')
          .that_requires('Apt::Source[hashicorp]')
      end

      it do
        is_expected.to contain_nebula__exposed_port('020 Consul LAN Serf (tcp)')
          .with_port(8301)
          .with_block('umich::networks::private_lan')
          .with_protocol('tcp')
      end

      it do
        is_expected.to contain_nebula__exposed_port('020 Consul LAN Serf (udp)')
          .with_port(8301)
          .with_block('umich::networks::private_lan')
          .with_protocol('udp')
      end

      [[8301,          'tcp', 'LAN Serf (tcp)'],
       [8301,          'udp', 'LAN Serf (udp)'],
       ['21000-21255', 'tcp', 'Sidecar Proxy'],
       ['21500-21755', 'tcp', 'Expose Check']].each do |port, protocol, service|
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
