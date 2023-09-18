# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::prometheus::exporter::node' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it do
        is_expected.to contain_file('/etc/default/prometheus-node-exporter')
          .that_notifies('Service[prometheus-node-exporter]')
          .that_requires('Package[prometheus-node-exporter]')
      end

      it do
        is_expected.to contain_file('/etc/systemd/system/prometheus-node-exporter.service')
          .that_notifies('Service[prometheus-node-exporter]')
          .that_requires('Package[prometheus-node-exporter]')
      end

      it do
        is_expected.to contain_file('/etc/rsyslog.d/prometheus-node-exporter.conf')
          .that_notifies('Service[prometheus-node-exporter]')
          .that_notifies('Service[rsyslog]')
      end

      it do
        is_expected.to contain_file('/var/log/prometheus-node-exporter.log')
          .with_owner('root')
          .with_group('adm')
          .with_mode('0640')
          .with_content('')
      end

      it { is_expected.to contain_service('prometheus-node-exporter') }

      it do
        is_expected.to contain_package('prometheus-node-exporter')
          .that_requires('User[prometheus]')
          .that_requires('File[/var/lib/prometheus/node-exporter]')
      end

      it do
        is_expected.to contain_file('/var/lib/prometheus/node-exporter')
          .with_ensure('directory')
          .with_mode('2775')
          .with_owner('prometheus')
          .with_group('prometheus')
          .that_requires('User[prometheus]')
          .that_requires('File[/var/lib/prometheus]')
      end

      it do
        is_expected.to contain_file('/var/lib/prometheus')
          .with_ensure('directory')
          .with_mode('2775')
          .with_owner('prometheus')
          .with_group('prometheus')
          .that_requires('User[prometheus]')
      end

      it { is_expected.to contain_package('curl') }
      it { is_expected.to contain_package('jq') }

      it do
        is_expected.to contain_file('/usr/local/bin/pushgateway')
          .with_mode('0755')
      end

      it "exports itself to the default datacenter's service discovery" do
        expect(exported_resources).to contain_concat_fragment("prometheus node service #{facts[:hostname]}")
          .with_tag('default_prometheus_node_service_list')
          .with_target('/etc/prometheus/nodes.yml')
          .with_content(%r{'#{facts[:ipaddress]}:9100'})
      end

      it "exports itself to the default datacenter's pushgateway" do
        expect(exported_resources).to contain_firewall("300 pushgateway #{facts[:hostname]} #{facts[:ipaddress]}")
          .with_tag('default_pushgateway_node')
          .with_proto('tcp')
          .with_dport(9091)
          .with_source(facts[:ipaddress])
          .with_state('NEW')
          .with_action('accept')
      end

      context 'with both public and private mlibrary_ip_addresses' do
        let(:facts) do
          os_facts.merge(mlibrary_ip_addresses: {
            "public": ["100.100.100.100", "200.200.200.200"],
            "private": ["10.1.2.3", "10.4.5.6"]
          })
        end

        it "exports itself to the default datacenter's service discovery" do
          expect(exported_resources).to contain_concat_fragment("prometheus node service #{facts[:hostname]}")
            .with_tag('default_prometheus_node_service_list')
            .with_target('/etc/prometheus/nodes.yml')
            .with_content(%r{'100\.100\.100\.100:9100'})
        end

        it "exports itself[0] to the default datacenter's pushgateway" do
          expect(exported_resources).to contain_firewall("300 pushgateway #{facts[:hostname]} 100.100.100.100")
            .with_tag('default_pushgateway_node')
            .with_source("100.100.100.100")
        end

        it "exports itself[1] to the default datacenter's pushgateway" do
          expect(exported_resources).to contain_firewall("300 pushgateway #{facts[:hostname]} 200.200.200.200")
            .with_tag('default_pushgateway_node')
            .with_source("200.200.200.200")
        end
      end

      context 'with only private ip addresses' do
        let(:facts) do
          os_facts.merge(mlibrary_ip_addresses: {
            "public": [],
            "private": ["10.1.2.3", "10.4.5.6"]
          })
        end

        it { is_expected.not_to compile }
      end

      context 'when our datacenter is covered' do
        let(:params) { { covered_datacenters: %w[mydatacenter] } }

        it "exports itself to its datacenter's service discovery" do
          expect(exported_resources).to contain_concat_fragment("prometheus node service #{facts[:hostname]}")
            .with_tag('mydatacenter_prometheus_node_service_list')
        end

        it "exports itself to its datacenter's pushgateway" do
          expect(exported_resources).to contain_firewall("300 pushgateway #{facts[:hostname]} #{facts[:ipaddress]}")
            .with_tag('mydatacenter_pushgateway_node')
            .with_source(facts[:ipaddress])
        end

        context 'with both public and private mlibrary_ip_addresses' do
          let(:facts) do
            os_facts.merge(mlibrary_ip_addresses: {
              "public": ["100.100.100.100", "200.200.200.200"],
              "private": ["10.1.2.3", "10.4.5.6"]
            })
          end

          it "exports itself to the default datacenter's service discovery" do
            expect(exported_resources).to contain_concat_fragment("prometheus node service #{facts[:hostname]}")
              .with_tag('mydatacenter_prometheus_node_service_list')
              .with_target('/etc/prometheus/nodes.yml')
              .with_content(%r{'10\.1\.2\.3:9100'})
          end

          it "exports itself[0] to its datacenter's pushgateway" do
            expect(exported_resources).to contain_firewall("300 pushgateway #{facts[:hostname]} 10.1.2.3")
              .with_tag('mydatacenter_pushgateway_node')
              .with_source("10.1.2.3")
          end

          it "exports itself[1] to its datacenter's pushgateway" do
            expect(exported_resources).to contain_firewall("300 pushgateway #{facts[:hostname]} 10.4.5.6")
              .with_tag('mydatacenter_pushgateway_node')
              .with_source("10.4.5.6")
          end
        end

        context 'with only public ip addresses' do
          let(:facts) do
            os_facts.merge(mlibrary_ip_addresses: {
              "public": ["100.100.100.100", "200.200.200.200"],
              "private": []
            })
          end

          it "exports itself to the default datacenter's service discovery" do
            expect(exported_resources).to contain_concat_fragment("prometheus node service #{facts[:hostname]}")
              .with_tag('mydatacenter_prometheus_node_service_list')
              .with_target('/etc/prometheus/nodes.yml')
              .with_content(%r{'100\.100\.100\.100:9100'})
          end

          it "exports itself[0] to the default datacenter's pushgateway" do
            expect(exported_resources).to contain_firewall("300 pushgateway #{facts[:hostname]} 100.100.100.100")
              .with_tag('mydatacenter_pushgateway_node')
              .with_source("100.100.100.100")
          end

          it "exports itself[1] to the default datacenter's pushgateway" do
            expect(exported_resources).to contain_firewall("300 pushgateway #{facts[:hostname]} 200.200.200.200")
              .with_tag('mydatacenter_pushgateway_node')
              .with_source("200.200.200.200")
          end
        end
      end

      it do
        is_expected.to contain_concat_file('/usr/local/bin/pushgateway_advanced')
          .with_mode('0755')
      end

      it do
        is_expected.to contain_concat_fragment('01 pushgateway advanced shebang')
          .with_target('/usr/local/bin/pushgateway_advanced')
          .with_content("#!/usr/bin/env bash\nset -eo pipefail\n\n")
      end

      it do
        is_expected.to contain_concat_fragment('03 main pushgateway advanced content')
          .with_target('/usr/local/bin/pushgateway_advanced')
      end

      context "with the default domain" do
        let(:node) { "dogbone.default.invalid" }

        it "exports only its hostname to prometheus service discovery" do
          expect(exported_resources).to contain_concat_fragment("prometheus node service dogbone")
            .with_content(%r{hostname: 'dogbone'})
        end
      end

      context "with a subdomain of the default domain" do
        let(:node) { "dogbone.doghouse.default.invalid" }

        it "exports its full fqdn to prometheus service discovery" do
          expect(exported_resources).to contain_concat_fragment("prometheus node service dogbone")
            .with_content(%r{hostname: 'dogbone\.doghouse\.default\.invalid'})
        end
      end

      context "with a nondefault domain" do
        let(:node) { "world.of.dogs" }

        it "exports its full fqdn to prometheus service discovery" do
          expect(exported_resources).to contain_concat_fragment("prometheus node service world")
            .with_content(%r{hostname: 'world\.of\.dogs'})
        end
      end
    end
  end
end
