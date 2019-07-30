# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::prometheus' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it do
        is_expected.to contain_docker__run('prometheus')
          .with_image('prom/prometheus:latest')
          .with_net('host')
          .with_extra_parameters(%w[--restart=always])
          .with_volumes(['/etc/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml',
                         '/etc/prometheus/rules.yml:/etc/prometheus/rules.yml',
                         '/etc/prometheus/nodes.yml:/etc/prometheus/nodes.yml',
                         '/opt/prometheus:/prometheus'])
          .that_requires('File[/opt/prometheus]')
      end

      context 'with version set to v2.11.1' do
        let(:params) { { version: 'v2.11.1' } }

        it do
          is_expected.to contain_docker__run('prometheus')
            .with_image('prom/prometheus:v2.11.1')
        end
      end

      it do
        is_expected.to contain_file('/etc/prometheus/prometheus.yml')
          .that_notifies('Docker::Run[prometheus]')
          .that_requires('File[/etc/prometheus]')
      end

      it do
        is_expected.to contain_file('/etc/prometheus/rules.yml')
          .that_notifies('Docker::Run[prometheus]')
          .that_requires('File[/etc/prometheus]')
      end

      it do
        is_expected.to contain_concat_file('/etc/prometheus/nodes.yml')
          .that_notifies('Docker::Run[prometheus]')
          .that_requires('File[/etc/prometheus]')
      end

      it do
        is_expected.to contain_file('/etc/prometheus')
          .with_ensure('directory')
      end

      it do
        is_expected.to contain_file('/opt/prometheus')
          .with_ensure('directory')
          .with_owner(65_534)
          .with_group(65_534)
      end

      it do
        is_expected.to contain_nebula__exposed_port('010 Prometheus HTTP')
          .with_port(9090)
          .with_block('umich::networks::all_trusted_machines')
      end

      it 'exports a firewall so that nodes can open 9100' do
        expect(exported_resources).to contain_firewall("010 prometheus node exporter #{facts[:hostname]}")
          .with_tag('mydatacenter_prometheus_node_exporter')
          .with_proto('tcp')
          .with_dport(9100)
          .with_source(facts[:ipaddress])
          .with_state('NEW')
          .with_action('accept')
      end
    end
  end
end
