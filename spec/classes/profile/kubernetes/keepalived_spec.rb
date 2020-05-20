# frozen_string_literal: true

# Copyright (c) 2019-2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::kubernetes::keepalived' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/first_cluster_config.yaml' }
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it { is_expected.to contain_class('Nebula::Profile::Networking::Sysctl') }
      it { is_expected.to contain_package('keepalived') }
      it { is_expected.to contain_package('ipset') }

      it do
        is_expected.to contain_service('keepalived')
          .with_ensure('running')
          .with_enable(true)
          .that_requires(['Package[keepalived]', 'Package[ipset]'])
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
          %r{virtual_ipaddress \{[^\}]*10\.0\.0\.1[^\}]*\}}m,
          %r{virtual_ipaddress \{[^\}]*172\.16\.0\.1 dev ens4[^\}]*\}}m,
          %r{virtual_ipaddress \{[^\}]*172\.16\.0\.6 dev ens4[^\}]*\}}m,
          %r{virtual_ipaddress \{[^\}]*172\.16\.0\.7 dev ens4[^\}]*\}}m,
        ].each do |content|
          it { is_expected.to contain_concat_fragment('keepalived preamble').with_content(content) }
        end

        context 'when cluster is set to second_cluster' do
          let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/second_cluster_config.yaml' }

          it 'exports its ip address for second_cluster keepalived peers' do
            expect(exported_resources).to contain_concat_fragment("keepalived #{os_facts[:hostname]}")
              .with_tag('second_cluster_keepalived')
          end

          it do
            is_expected.to contain_concat_fragment('keepalived preamble')
              .with_content(%r{virtual_ipaddress \{[^\}]*10\.0\.0\.2[^\}]*\}}m)
              .with_content(%r{virtual_ipaddress \{[^\}]*172\.16\.1\.1 dev ens4[^\}]*\}}m)
              .with_content(%r{virtual_ipaddress \{[^\}]*172\.16\.1\.6 dev ens4[^\}]*\}}m)
              .with_content(%r{virtual_ipaddress \{[^\}]*172\.16\.1\.7 dev ens4[^\}]*\}}m)
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
            .that_notifies(['Service[keepalived]', 'Service[procps]'])
        end
      end
    end
  end
end
