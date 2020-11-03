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
                         '/etc/prometheus/haproxy.yml:/etc/prometheus/haproxy.yml',
                         '/etc/prometheus/mysql.yml:/etc/prometheus/mysql.yml',
                         '/etc/prometheus/tls:/tls',
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

      context 'with rules_variables set' do
        let(:params) do
          {
            rules_variables: {
              darkblue_device: '//storage.invalid/volume',
            },
          }
        end

        it do
          is_expected.to contain_file('/etc/prometheus/rules.yml')
            .that_notifies('Docker::Run[prometheus]')
            .that_requires('File[/etc/prometheus]')
            .with_content(%r{device="//storage.invalid/volume"})
        end
      end

      it do
        is_expected.to contain_concat_file('/etc/prometheus/nodes.yml')
          .that_notifies('Docker::Run[prometheus]')
          .that_requires('File[/etc/prometheus]')
      end

      it do
        is_expected.to contain_concat_file('/etc/prometheus/haproxy.yml')
          .that_notifies('Docker::Run[prometheus]')
          .that_requires('File[/etc/prometheus]')
      end

      it do
        is_expected.to contain_concat_file('/etc/prometheus/mysql.yml')
          .that_notifies('Docker::Run[prometheus]')
          .that_requires('File[/etc/prometheus]')
      end

      it do
        is_expected.to contain_file('/etc/prometheus')
          .with_ensure('directory')
      end

      it do
        is_expected.to contain_file('/etc/prometheus/tls')
          .with_ensure('directory')
          .that_requires('File[/etc/prometheus]')
      end

      it do
        is_expected.to contain_file('/etc/prometheus/tls/ca.crt')
          .with_source('puppet:///ssl-certs/prometheus-pki/ca.crt')
          .that_requires('File[/etc/prometheus/tls]')
      end

      it do
        is_expected.to contain_file('/etc/prometheus/tls/client.crt')
          .with_source("puppet:///ssl-certs/prometheus-pki/#{facts[:fqdn]}.crt")
          .that_requires('File[/etc/prometheus/tls]')
      end

      it do
        is_expected.to contain_file('/etc/prometheus/tls/client.key')
          .with_source("puppet:///ssl-certs/prometheus-pki/#{facts[:fqdn]}.key")
          .that_requires('File[/etc/prometheus/tls]')
      end

      %w[ca.crt client.crt client.key].each do |filename|
        it do
          is_expected.to contain_docker__run('prometheus')
            .that_requires("File[/etc/prometheus/tls/#{filename}]")
        end
      end

      it do
        is_expected.to contain_file('/opt/prometheus')
          .with_ensure('directory')
          .with_owner(65_534)
          .with_group(65_534)
      end

      it do
        is_expected.to contain_class('nebula::profile::https_to_port')
          .with_port(9090)
      end

      it do
        is_expected.to contain_nebula__exposed_port('010 Prometheus HTTPS')
          .with_port(443)
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

      it 'exports a firewall so that haproxy nodes can open 9101' do
        expect(exported_resources).to contain_firewall("010 prometheus haproxy exporter #{facts[:hostname]}")
          .with_tag('mydatacenter_prometheus_haproxy_exporter')
          .with_proto('tcp')
          .with_dport(9101)
          .with_source(facts[:ipaddress])
          .with_state('NEW')
          .with_action('accept')
      end

      context 'with some static nodes set' do
        let(:fragment) { 'prometheus node service static_host' }
        let(:params) do
          {
            static_nodes: [
              {
                'targets'      => ['10.9.9.99:1234'],
                'labels'       => {
                  'datacenter' => 'static_datacenter',
                  'hostname'   => 'static_host',
                  'role'       => 'static::role',
                },
              },
            ],
          }
        end

        it do
          is_expected.to contain_concat_fragment(fragment)
            .with_tag('mydatacenter_prometheus_node_service_list')
            .with_target('/etc/prometheus/nodes.yml')
        end

        [
          %r{^- targets: \[ '10\.9\.9\.99:1234' \]$},
          %r{^  labels:$},
          %r{^    datacenter: 'static_datacenter'$},
          %r{^    hostname: 'static_host'$},
          %r{^    role: 'static::role'$},
        ].each do |content|
          it { is_expected.to contain_concat_fragment(fragment).with_content(content) }
        end
      end

      it do
        is_expected.to contain_file('/etc/prometheus/prometheus.yml')
          .without_content(%r{job_name: wmi})
      end

      context 'with some static wmi nodes set' do
        let(:params) do
          {
            static_wmi_nodes: [
              {
                'targets' => ['10.11.12.13:9182'],
                'labels' => {
                  'datacenter' => 'windows_center',
                  'hostname' => 'windows_host',
                  'role' => 'windows::role',
                },
              },
            ],
          }
        end

        [
          "datacenter: 'windows_center'",
          "hostname: 'windows_host'",
          "role: 'windows::role'",
        ].each do |label|
          it do
            is_expected.to contain_file('/etc/prometheus/prometheus.yml')
              .with_content(%r{job_name: wmi\n.*labels:\n.*#{label}}m)
          end
        end
      end
    end
  end
end
