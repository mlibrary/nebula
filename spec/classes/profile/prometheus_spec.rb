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
                         '/etc/prometheus/ipmi.yml:/etc/prometheus/ipmi.yml',
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
        is_expected.to contain_docker__run('pushgateway')
          .with_image('prom/pushgateway:latest')
          .with_command('--persistence.file=/archive/pushgateway')
          .with_net('host')
          .with_extra_parameters(%w[--restart=always])
          .with_volumes(%w[/opt/pushgateway:/archive])
          .that_requires('File[/opt/pushgateway]')
      end

      context 'with pushgateway_version set to v2.11.1' do
        let(:params) { { pushgateway_version: 'v2.11.1' } }

        it do
          is_expected.to contain_docker__run('pushgateway')
            .with_image('prom/pushgateway:v2.11.1')
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
        is_expected.to contain_concat_file('/etc/prometheus/ipmi.yml')
          .that_notifies('Docker::Run[prometheus]')
          .that_requires('File[/etc/prometheus]')
      end

      it do
        is_expected.to contain_concat_fragment("prometheus ipmi scrape config first line")
          .with_target('/etc/prometheus/ipmi.yml')
          .with_order("01")
          .with_content("scrape_configs:\n")
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
        is_expected.to contain_file('/opt/pushgateway')
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

      [["haproxy", 9101],
       ["mysql", 9104]].each do |exporter, port|
        it "exports a firewall so that #{exporter} exporters can open #{port}" do
          expect(exported_resources).to contain_firewall("010 prometheus #{exporter} exporter #{facts[:hostname]}")
            .with_tag("mydatacenter_prometheus_#{exporter}_exporter")
            .with_proto('tcp')
            .with_dport(port)
            .with_source(facts[:ipaddress])
            .with_state('NEW')
            .with_action('accept')
        end
      end

      it 'exports a firewall so that nodes can open 9100' do
        expect(exported_resources).to contain_firewall("010 prometheus legacy node exporter #{facts[:hostname]}")
          .with_tag('mydatacenter_prometheus_node_exporter')
          .with_proto('tcp')
          .with_dport(9100)
          .with_source(facts[:ipaddress])
          .with_state('NEW')
          .with_action('accept')
      end

      context 'with no mlibrary_ip_addresses fact' do
        let(:facts) do
          os_facts.merge(mlibrary_ip_addresses: nil)
        end

        it { is_expected.to compile }

        it do
          expect(exported_resources).to contain_concat_fragment('02 pushgateway advanced url mydatacenter')
            .with_target('/usr/local/bin/pushgateway_advanced')
            .with_content("PUSHGATEWAY='http://#{facts[:ipaddress]}:9091'\n")
        end

        it do
          expect(exported_resources).to contain_concat_fragment('02 pushgateway advanced public url mydatacenter')
            .with_target('/usr/local/bin/pushgateway_advanced')
            .with_content("PUSHGATEWAY='http://#{facts[:ipaddress]}:9091'\n")
        end

        it do
          expect(exported_resources).not_to contain_concat_fragment('02 pushgateway advanced private url mydatacenter')
        end
      end

      context 'with a single public ip address in mlibrary_ip_addresses' do
        let(:facts) do
          os_facts.merge(mlibrary_ip_addresses: {
            "public"  => ["100.100.100.100"],
            "private" => []
          })
        end

        it do
          expect(exported_resources).to contain_firewall("010 prometheus public node exporter #{facts[:hostname]} 100.100.100.100")
            .with_source("100.100.100.100")
            .with_tag('mydatacenter_prometheus_public_node_exporter')
        end

        it do
          expect(exported_resources).to contain_concat_fragment('02 pushgateway advanced url mydatacenter')
            .with_target('/usr/local/bin/pushgateway_advanced')
            .with_content("PUSHGATEWAY='http://100.100.100.100:9091'\n")
        end

        it do
          expect(exported_resources).to contain_concat_fragment('02 pushgateway advanced public url mydatacenter')
            .with_target('/usr/local/bin/pushgateway_advanced')
            .with_content("PUSHGATEWAY='http://100.100.100.100:9091'\n")
        end

        it do
          expect(exported_resources).not_to contain_concat_fragment('02 pushgateway advanced private url mydatacenter')
        end
      end

      context 'with two public ip addresses in mlibrary_ip_addresses' do
        let(:facts) do
          os_facts.merge(mlibrary_ip_addresses: {
            "public"  => ["100.100.100.100", "200.200.200.200"],
            "private" => []
          })
        end

        it do
          expect(exported_resources).to contain_firewall("010 prometheus public node exporter #{facts[:hostname]} 100.100.100.100")
            .with_source("100.100.100.100")
            .with_tag('mydatacenter_prometheus_public_node_exporter')
        end

        it do
          expect(exported_resources).to contain_firewall("010 prometheus public node exporter #{facts[:hostname]} 200.200.200.200")
            .with_source("200.200.200.200")
            .with_tag('mydatacenter_prometheus_public_node_exporter')
        end

        it do
          expect(exported_resources).to contain_concat_fragment('02 pushgateway advanced url mydatacenter')
            .with_target('/usr/local/bin/pushgateway_advanced')
            .with_content("PUSHGATEWAY='http://100.100.100.100:9091'\n")
        end

        it do
          expect(exported_resources).to contain_concat_fragment('02 pushgateway advanced public url mydatacenter')
            .with_target('/usr/local/bin/pushgateway_advanced')
            .with_content("PUSHGATEWAY='http://100.100.100.100:9091'\n")
        end

        it do
          expect(exported_resources).not_to contain_concat_fragment('02 pushgateway advanced private url mydatacenter')
        end
      end

      context 'with a single private ip address in mlibrary_ip_addresses' do
        let(:facts) do
          os_facts.merge(mlibrary_ip_addresses: {
            "public"  => [],
            "private" => ["10.1.2.3"]
          })
        end

        it do
          expect(exported_resources).to contain_firewall("010 prometheus private node exporter #{facts[:hostname]} 10.1.2.3")
            .with_source("10.1.2.3")
            .with_tag('mydatacenter_prometheus_private_node_exporter')
        end

        it do
          expect(exported_resources).not_to contain_concat_fragment('02 pushgateway advanced url mydatacenter')
        end

        it do
          expect(exported_resources).not_to contain_concat_fragment('02 pushgateway advanced public url mydatacenter')
        end

        it do
          expect(exported_resources).to contain_concat_fragment('02 pushgateway advanced private url mydatacenter')
            .with_target('/usr/local/bin/pushgateway_advanced')
            .with_content("PUSHGATEWAY='http://10.1.2.3:9091'\n")
        end
      end

      context 'with too many ip addresses in mlibrary_ip_addresses' do
        let(:facts) do
          os_facts.merge(mlibrary_ip_addresses: {
            "public"  => ["100.100.100.100", "200.200.200.200"],
            "private" => ["10.1.2.3", "10.2.3.4", "10.3.4.5"]
          })
        end

        [%w[public 100.100.100.100],
         %w[public 200.200.200.200],
         %w[private 10.1.2.3],
         %w[private 10.2.3.4],
         %w[private 10.3.4.5]].each do |network, ip_address|
          [["node", 9100],
           ["ipmi", 9290]].each do |exporter, port|
            it "exports a firewall so that #{exporter} exporters can open #{network} #{port} to #{ip_address}" do
              expect(exported_resources).to contain_firewall("010 prometheus #{network} #{exporter} exporter #{facts[:hostname]} #{ip_address}")
                .with_tag("mydatacenter_prometheus_#{network}_#{exporter}_exporter")
                .with_proto('tcp')
                .with_dport(port)
                .with_source(ip_address)
                .with_state('NEW')
                .with_action('accept')
            end
          end
        end

        it do
          expect(exported_resources).to contain_concat_fragment('02 pushgateway advanced url mydatacenter')
            .with_target('/usr/local/bin/pushgateway_advanced')
            .with_content("PUSHGATEWAY='http://100.100.100.100:9091'\n")
        end

        it do
          expect(exported_resources).to contain_concat_fragment('02 pushgateway advanced public url mydatacenter')
            .with_target('/usr/local/bin/pushgateway_advanced')
            .with_content("PUSHGATEWAY='http://100.100.100.100:9091'\n")
        end

        it do
          expect(exported_resources).to contain_concat_fragment('02 pushgateway advanced private url mydatacenter')
            .with_target('/usr/local/bin/pushgateway_advanced')
            .with_content("PUSHGATEWAY='http://10.1.2.3:9091'\n")
        end
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
