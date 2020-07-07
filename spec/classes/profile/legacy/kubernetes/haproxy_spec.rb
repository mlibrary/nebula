# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::legacy::kubernetes::haproxy' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:hiera_config) { 'spec/fixtures/hiera/legacy_kubernetes_config.yaml' }
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it do
        is_expected.to contain_nebula__exposed_port('200 kubectl')
          .with_port(6443)
          .with_block('umich::networks::all_trusted_machines')
      end

      it do
        is_expected.to contain_nebula__exposed_port('300 NodePorts')
          .with_port('30000-32767')
          .with_block('umich::networks::all_trusted_machines')
      end

      it { is_expected.to contain_class('Nebula::Profile::Networking::Sysctl') }
      it { is_expected.to contain_package('haproxy') }
      it { is_expected.to contain_package('haproxyctl') }
      it { is_expected.to contain_package('keepalived') }
      it { is_expected.to contain_package('ipset') }

      it do
        is_expected.to contain_service('haproxy')
          .with_ensure('running')
          .with_enable(true)
          .that_requires('Package[haproxy]')
      end

      it do
        is_expected.to contain_service('keepalived')
          .with_ensure('running')
          .with_enable(true)
          .that_requires(['Package[keepalived]', 'Package[ipset]'])
          .that_notifies('Service[haproxy]')
      end

      describe '/etc/keepalived/keepalived.conf' do
        let(:file) { '/etc/keepalived/keepalived.conf' }

        it do
          is_expected.to contain_concat(file)
            .that_notifies('Service[keepalived]')
        end

        it do
          is_expected.to contain_concat_fragment('keepalived preamble')
            .with_target(file)
            .with_order('01')
        end

        it 'exports its ip address for first_cluster keepalived peers' do
          expect(exported_resources).to contain_concat_fragment("keepalived #{os_facts[:hostname]}")
            .with_target(file)
            .with_order('02')
            .with_content(%r{^\s*#{os_facts[:ipaddress]}\s*$}m)
            .with_tag('first_cluster_keepalived')
        end

        it do
          is_expected.to contain_concat_fragment('keepalived postamble')
            .with_target(file)
            .with_order('99')
        end

        [
          %r{root@default.invalid},
          %r{state BACKUP},
          %r{priority 100},
          %r{unicast_src_ip #{os_facts[:ipaddress]}},
          %r{virtual_ipaddress \{\s*10\.0\.0\.1\s*\}}m,
        ].each do |content|
          it { is_expected.to contain_concat_fragment('keepalived preamble').with_content(content) }
        end

        context 'when cluster is set to second_cluster' do
          let(:params) { { cluster: 'second_cluster' } }

          it 'exports its ip address for second_cluster keepalived peers' do
            expect(exported_resources).to contain_concat_fragment("keepalived #{os_facts[:hostname]}")
              .with_tag('second_cluster_keepalived')
          end

          it do
            is_expected.to contain_concat_fragment('keepalived preamble')
              .with_content(%r{virtual_ipaddress \{\s*10\.0\.0\.2\s*\}}m)
          end
        end

        context 'when master is true' do
          let(:params) { { master: true } }

          [
            %r{state MASTER},
            %r{priority 101},
          ].each do |content|
            it { is_expected.to contain_concat_fragment('keepalived preamble').with_content(content) }
          end
        end
      end

      describe '/etc/sysctl.d/keepalived.conf' do
        let(:file) { '/etc/sysctl.d/keepalived.conf' }

        it do
          is_expected.to contain_file(file)
            .with_content(%r{^net.ipv4.ip_nonlocal_bind = 1$})
            .that_notifies(['Service[keepalived]', 'Service[procps]', 'Service[haproxy]'])
        end
      end

      it do
        is_expected.to contain_nebula__authzd_user('haproxyctl')
          .with_gid('haproxy')
          .with_home('/var/haproxyctl')
      end

      describe '/etc/default/haproxy' do
        let(:file) { '/etc/default/haproxy' }

        it do
          is_expected.to contain_file(file)
            .with_content(%r{^CONFIG="/etc/haproxy/haproxy.cfg"$})
            .that_notifies(['Service[haproxy]', 'Service[keepalived]'])
        end
      end

      describe '/etc/haproxy/haproxy.cfg' do
        let(:file) { '/etc/haproxy/haproxy.cfg' }

        it do
          is_expected.to contain_concat(file)
            .that_notifies(['Service[haproxy]', 'Service[keepalived]'])
        end

        it do
          is_expected.to contain_concat_fragment('haproxy defaults')
            .with_target(file)
            .with_order('01')
        end

        it do
          is_expected.to contain_concat_fragment('haproxy nodeports')
            .with_target(file)
            .with_order('03')
            .with_content("\nlisten nodeports\n  bind 10.0.0.1:30000-32767\n  mode tcp\n  option tcp-check\n  balance roundrobin\n")
        end
      end

      describe '/etc/kubernetes_addresses.yaml' do
        let(:file) { '/etc/kubernetes_addresses.yaml' }

        it { is_expected.to contain_concat_file(file).with_format('yaml') }

        it do
          is_expected.to contain_concat_fragment('haproxy floating ip')
            .with_target(file)
            .with_content("addresses: {floating: {first_cluster: '10.0.0.1'}}")
        end

        it do
          is_expected.to contain_concat_fragment('haproxy unicast ip')
            .with_target(file)
            .with_content("addresses: {unicast: {#{os_facts[:hostname]}: '#{os_facts[:ipaddress]}'}}")
        end
      end

      describe 'exported resources' do
        subject { exported_resources }

        it do
          is_expected.to contain_firewall("200 kubectl: #{os_facts[:hostname]}")
            .with_dport(6443)
            .with_source(os_facts[:ipaddress])
            .with_tag('first_cluster_haproxy_kubectl')
        end

        it do
          is_expected.to contain_firewall("300 NodePorts: #{os_facts[:hostname]}")
            .with_dport('30000-32767')
            .with_source(os_facts[:ipaddress])
            .with_tag('first_cluster_haproxy_nodeports')
        end

        it do
          is_expected.to contain_concat_fragment("haproxy ip #{os_facts[:hostname]}")
            .with_target('/etc/kubernetes_addresses.yaml')
            .with_content("addresses: {peers: {#{os_facts[:hostname]}: '#{os_facts[:ipaddress]}'}}")
            .with_tag('first_cluster_proxy_ips')
        end
      end
    end
  end
end
