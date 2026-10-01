# frozen_string_literal: true

# Copyright (c) 2025 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require "spec_helper"

describe "nebula::profile::prometheus" do
  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_package("prometheus") }
      it { is_expected.to contain_service("prometheus") }
      it { is_expected.to contain_package("prometheus-pushgateway") }
      it { is_expected.to contain_service("prometheus-pushgateway") }

      it do
        is_expected.to contain_exec("divert /etc/prometheus/prometheus.yml")
          .with_command("/usr/bin/dpkg-divert --rename --divert /etc/prometheus/prometheus.yml.dist --add /etc/prometheus/prometheus.yml")
          .with_creates("/etc/prometheus/prometheus.yml.dist")
          .that_requires("Package[prometheus]")
      end

      it do
        is_expected.to contain_exec("divert /etc/default/prometheus-pushgateway")
          .with_command("/usr/bin/dpkg-divert --rename --divert /etc/default/prometheus-pushgateway.dist --add /etc/default/prometheus-pushgateway")
          .with_creates("/etc/default/prometheus-pushgateway.dist")
          .that_requires("Package[prometheus-pushgateway]")
      end

      it do
        is_expected.to contain_file("/etc/prometheus/prometheus.yml")
          .that_notifies("Service[prometheus]")
          .that_requires("Exec[divert /etc/prometheus/prometheus.yml]")
      end

      it do
        is_expected.to contain_file("/var/lib/prometheus/pushgateway")
          .with_ensure("directory")
          .with_owner("prometheus")
          .with_group("prometheus")
      end

      it do
        is_expected.to contain_file("/etc/default/prometheus-pushgateway")
          .with_content("ARGS=\"--persistence.file=/var/lib/prometheus/pushgateway/archive\"\n")
          .that_notifies("Service[prometheus-pushgateway]")
          .that_requires("Exec[divert /etc/default/prometheus-pushgateway]")
          .that_requires("File[/var/lib/prometheus/pushgateway]")
      end

      it do
        is_expected.to contain_file("/etc/prometheus/rules.yml")
          .that_notifies("Service[prometheus]")
          .that_requires("Package[prometheus]")
      end

      [
        %w[node /etc/prometheus/nodes.yml],
        %w[haproxy /etc/prometheus/haproxy.yml],
        %w[mysql /etc/prometheus/mysql.yml],
        %w[ipmi /etc/prometheus/ipmi.yml],
        %w[etcd /etc/prometheus/etcd.yml],
        %w[catalog_search /etc/prometheus/catalog_search.yml],
        %w[quod /etc/prometheus/quod.yml],
      ].each do |exporter, config_path|
        it do
          is_expected.to contain_nebula__file_that_pulls_in_exported_fragments(config_path)
            .with_fragment_tag("mydatacenter_prometheus_#{exporter}_service_list")
        end

        it do
          is_expected.to contain_concat(config_path)
            .that_notifies("Service[prometheus]")
            .that_requires("Package[prometheus]")
        end

        context 'in datacenter abc' do
          let(:facts) { os_facts.merge(datacenter: "abc") }

          it do
            is_expected.to contain_nebula__file_that_pulls_in_exported_fragments(config_path)
              .with_fragment_tag("abc_prometheus_#{exporter}_service_list")
          end
        end
      end

      context 'with 2 static nodes, abc1 and abc2' do
        let(:params) do
          {
            static_nodes: [
              {
                targets: ["10.1.1.1:9100"],
                labels: {
                  datacenter: facts["datacenter"],
                  hostname: "abc1",
                  role: "dont_care",
                }
              },
              {
                targets: ["10.2.2.2:9100"],
                labels: {
                  datacenter: facts["datacenter"],
                  hostname: "abc2",
                  role: "dont_care",
                }
              },
            ]
          }
        end

        it { is_expected.to contain_concat__fragment("prometheus node service abc1") }

        it do
          is_expected.to contain_concat__fragment("prometheus node service abc2")
            .with_target("/etc/prometheus/nodes.yml")
        end
      end

      it do
        is_expected.to contain_concat__fragment("prometheus ipmi scrape config first line")
          .with_target("/etc/prometheus/ipmi.yml")
          .with_order("01")
          .with_content("scrape_configs:\n")
      end

      it { is_expected.to contain_file("/etc/prometheus/tls").with_ensure("directory") }
      it { is_expected.to contain_file("/etc/prometheus/tls").that_requires("Package[prometheus]") }

      it do
        is_expected.to contain_file("/etc/prometheus/tls/ca.crt")
          .with_source("puppet:///ssl-certs/prometheus-pki/ca.crt")
          .with_mode("0644")
          .with_owner("prometheus")
          .with_group("prometheus")
          .that_notifies("Service[prometheus]")
          .that_requires("File[/etc/prometheus/tls]")
      end

      it do
        is_expected.to contain_file("/etc/prometheus/tls/tls.crt")
          .with_source("puppet:///ssl-certs/prometheus-pki/#{facts[:networking]["fqdn"]}.crt")
          .with_mode("0644")
          .with_owner("prometheus")
          .with_group("prometheus")
          .that_notifies("Service[prometheus]")
          .that_requires("File[/etc/prometheus/tls]")
      end

      it do
        is_expected.to contain_file("/etc/prometheus/tls/tls.key")
          .with_source("puppet:///ssl-certs/prometheus-pki/#{facts[:networking]["fqdn"]}.key")
          .with_mode("0600")
          .with_owner("prometheus")
          .with_group("prometheus")
          .that_notifies("Service[prometheus]")
          .that_requires("File[/etc/prometheus/tls]")
      end

      context "with an fqdn of abc.example.net" do
        let(:facts) do
          os_facts.merge(
            networking: os_facts[:networking].merge(
              "fqdn" => "abc.example.net"
            )
          )
        end

        it do
          is_expected.to contain_file("/etc/prometheus/tls/tls.crt")
            .with_source("puppet:///ssl-certs/prometheus-pki/abc.example.net.crt")
        end

        it do
          is_expected.to contain_file("/etc/prometheus/tls/tls.key")
            .with_source("puppet:///ssl-certs/prometheus-pki/abc.example.net.key")
        end
      end
    end
  end
end
