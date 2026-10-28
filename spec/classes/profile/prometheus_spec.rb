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
        %w[quod /etc/prometheus/quod.yml]
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

        context "in datacenter abc" do
          let(:facts) { os_facts.merge(datacenter: "abc") }

          it do
            is_expected.to contain_nebula__file_that_pulls_in_exported_fragments(config_path)
              .with_fragment_tag("abc_prometheus_#{exporter}_service_list")
          end
        end
      end

      context "with 2 static nodes, abc1 and abc2" do
        let(:params) do
          {
            static_nodes: [
              {
                targets: ["10.1.1.1:9100"],
                labels: {
                  datacenter: facts["datacenter"],
                  hostname: "abc1",
                  role: "dont_care"
                }
              },
              {
                targets: ["10.2.2.2:9100"],
                labels: {
                  datacenter: facts["datacenter"],
                  hostname: "abc2",
                  role: "dont_care"
                }
              }
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

      it do
        expect(exported_resources).to contain_concat__fragment("02 pushgateway advanced public url mydatacenter")
          .with_target("/usr/local/bin/pushgateway_advanced")
          .with_content("PUSHGATEWAY='http://123.123.123.123:9091'\n")
      end

      it do
        expect(exported_resources).to contain_concat__fragment("02 pushgateway advanced private url mydatacenter")
          .with_target("/usr/local/bin/pushgateway_advanced")
          .with_content("PUSHGATEWAY='http://10.123.123.123:9091'\n")
      end

      it do
        expect(exported_resources).to contain_firewall("010 prometheus public node exporter #{facts[:networking]["hostname"]} 123.123.123.123")
          .with_tag("mydatacenter_prometheus_public_node_exporter")
          .with_source("123.123.123.123")
          .with_proto("tcp")
          .with_state("NEW")
          .with_jump("accept")
          .with_dport(9100)
      end

      it do
        expect(exported_resources).to contain_firewall("010 prometheus private node exporter #{facts[:networking]["hostname"]} 10.123.123.123")
          .with_tag("mydatacenter_prometheus_private_node_exporter")
          .with_source("10.123.123.123")
          .with_proto("tcp")
          .with_state("NEW")
          .with_jump("accept")
          .with_dport(9100)
      end

      context "in datacenter abc123" do
        let(:facts) { os_facts.merge(datacenter: "abc123") }

        it { expect(exported_resources).to contain_concat__fragment("02 pushgateway advanced public url abc123") }
        it { expect(exported_resources).to contain_concat__fragment("02 pushgateway advanced private url abc123") }
      end

      context "when on the public internet" do
        let(:facts) do
          os_facts.merge(
            mlibrary_ip_addresses: {
              "public" => %w[10.1.1.1],
              "private" => %w[10.2.2.2]
            }
          )
        end

        it { is_expected.not_to contain_nginx__resource__server("prometheus") }
        it { is_expected.not_to contain_firewall("200 HTTPS: Client Cert") }

        it { is_expected.to contain_class("nebula::profile::https_to_port").with_port(9090) }
        it { is_expected.to contain_nebula__exposed_port("010 Prometheus HTTPS").with_port(443) }
        it { is_expected.to contain_nebula__exposed_port("010 Prometheus HTTPS").with_block("umich::networks::all_trusted_machines") }

        it do
          expect(exported_resources).to contain_concat__fragment("02 pushgateway advanced public url mydatacenter")
            .with_content("PUSHGATEWAY='http://10.1.1.1:9091'\n")
        end

        it do
          expect(exported_resources).to contain_concat__fragment("02 pushgateway advanced private url mydatacenter")
            .with_content("PUSHGATEWAY='http://10.2.2.2:9091'\n")
        end
      end

      context "when behind a NAT router" do
        let(:facts) do
          os_facts.merge(
            mlibrary_ip_addresses: {
              "public" => [],
              "private" => %w[10.3.3.3]
            }
          )
        end

        it { is_expected.not_to contain_class("nebula::profile::https_to_port") }
        it { is_expected.not_to contain_nebula__exposed_port("010 Prometheus HTTPS") }

        it { is_expected.to contain_class("nginx").with_server_tokens("off") }

        it do
          is_expected.to contain_nginx__resource__server("prometheus")
            .with_server_name([facts[:networking]["fqdn"]])
            .with_listen_options("proxy_protocol default_server")
            .with_listen_port(443)
            .with_proxy("http://localhost:9090")
            .with_ssl(true)
            .with_ssl_cert("/etc/prometheus/tls/tls.crt")
            .with_ssl_key("/etc/prometheus/tls/tls.key")
            .with_server_cfg_append(
              "ssl_client_certificate" => "/etc/prometheus/tls/ca.crt",
              "ssl_verify_client" => "on",
              "ssl_verify_depth" => 1
            )
        end

        it do
          is_expected.to contain_firewall("200 HTTPS: Client Cert")
            .with_proto("tcp")
            .with_dport([443])
            .with_state("NEW")
            .with_jump("accept")
        end

        it { expect(exported_resources).not_to contain_concat__fragment("02 pushgateway advanced public url mydatacenter") }

        it do
          expect(exported_resources).to contain_concat__fragment("02 pushgateway advanced private url mydatacenter")
            .with_content("PUSHGATEWAY='http://10.3.3.3:9091'\n")
        end
      end

      context "when public ip addresses are null" do
        let(:facts) do
          os_facts.merge(
            mlibrary_ip_addresses: {
              "public" => nil,
              "private" => %w[10.3.3.3]
            }
          )
        end

        it { is_expected.not_to contain_class("nebula::profile::https_to_port") }
        it { is_expected.not_to contain_nebula__exposed_port("010 Prometheus HTTPS") }
        it { expect(exported_resources).not_to contain_concat__fragment("02 pushgateway advanced public url mydatacenter") }
      end
    end
  end
end
