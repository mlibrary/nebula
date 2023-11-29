# frozen_string_literal: true

# Copyright (c) 2023 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::prometheus::exporter::ipmi' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge(mlibrary_ip_addresses: {
          "public" => [os_facts[:ipaddress]],
          "private" => []
        })
      end

      it { is_expected.to compile }
      it { is_expected.not_to contain_service("kubelet") }
      it { is_expected.not_to contain_file("/etc/prometheus") }
      it { is_expected.not_to contain_file("/etc/prometheus/ipmi.yaml") }
      it { expect(exported_resources).not_to contain_concat_fragment("prometheus ipmi scrape config #{facts[:hostname]}") }

      context "with an account set" do
        let(:params) do
          { accounts: {
            "remote-ipmi.example" => {
              "username" => "myuser123",
              "password" => "!!secret!!"
            }
          }}
        end

        it { is_expected.to compile }
        it { is_expected.to contain_service("kubelet") }
        it { is_expected.to contain_file("/etc/kubernetes/manifests/ipmi_exporter.yaml") }

        it { is_expected.to contain_file("/etc/prometheus").with_ensure("directory") }

        it do
          is_expected.to contain_file("/etc/prometheus/ipmi.yaml")
            .that_requires("File[/etc/prometheus]")
            .with_content(/remote-ipmi.example:\n *user: "myuser123"\n *pass: "!!secret!!"/m)
            .with_content(/^ *privilege: "user"$/)
            .with_content(/^ *timeout: 20000$/)
            .with_content(/^ *driver: "LAN_2_0"$/)
            .with_content(/collectors:\n *- "bmc"\n *- "ipmi"\n *- "chassis"/m)
            .without_content(/exclude_sensor_ids/)
        end

        it do
          expect(exported_resources).to contain_concat_fragment("prometheus ipmi scrape config #{facts[:hostname]}")
            .with_tag("mydatacenter_prometheus_ipmi_exporter")
            .with_target("/etc/prometheus/ipmi.yml")
            .with_order("02")
            .with_content(/^ +- +"remote-ipmi.example"$/)
            .with_content(/^ +datacenter: "mydatacenter"$/)
            .with_content(/^ +via: "#{facts[:hostname]}"$/)
            .with_content(/^ +replacement: "#{facts[:ipaddress]}:9290"$/)
        end
      end

      context "with two accounts set" do
        let(:params) do
          { accounts: {
            "ipmi-1.example" => {
              "username" => "myuser1",
              "password" => "mysecret1"
            },
            "ipmi-2.example" => {
              "username" => "myuser2",
              "password" => "mysecret2"
            }
          }}
        end

        it do
          is_expected.to contain_file("/etc/prometheus/ipmi.yaml")
            .with_content(/ipmi-1.example:\n *user: "myuser1"\n *pass: "mysecret1"/m)
        end

        it do
          is_expected.to contain_file("/etc/prometheus/ipmi.yaml")
            .with_content(/ipmi-2.example:\n *user: "myuser2"\n *pass: "mysecret2"/m)
        end

        it do
          expect(exported_resources).to contain_concat_fragment("prometheus ipmi scrape config #{facts[:hostname]}")
            .with_content(/^ +- +"ipmi-1.example"$/)
            .with_content(/^ +- +"ipmi-2.example"$/)
        end
      end

      context "with overridden privilege" do
        let(:params) do
          { accounts: {
            "ipmi.example" => {
              "username" => "abc123",
              "password" => "!!secret!!",
              "privilege" => "admin"
            }
          }}
        end

        it do
          is_expected.to contain_file("/etc/prometheus/ipmi.yaml")
            .with_content(/^ *privilege: "admin"$/)
        end

        it do
          expect(exported_resources).to contain_concat_fragment("prometheus ipmi scrape config #{facts[:hostname]}")
            .with_content(/^ +- +"ipmi.example"$/)
        end
      end

      context "with overridden timeout" do
        let(:params) do
          { accounts: {
            "ipmi.example" => {
              "username" => "abc123",
              "password" => "!!secret!!",
              "timeout" => 60_000
            }
          }}
        end

        it do
          is_expected.to contain_file("/etc/prometheus/ipmi.yaml")
            .with_content(/^ *timeout: 60000$/)
        end
      end

      context "with overridden driver" do
        let(:params) do
          { accounts: {
            "ipmi.example" => {
              "username" => "abc123",
              "password" => "!!secret!!",
              "driver" => "LAN"
            }
          }}
        end

        it do
          is_expected.to contain_file("/etc/prometheus/ipmi.yaml")
            .with_content(/^ *driver: "LAN"$/)
        end
      end

      context "with overridden collectors" do
        let(:params) do
          { accounts: {
            "ipmi.example" => {
              "username" => "abc123",
              "password" => "!!secret!!",
              "collectors" => %w[ipmi sel dcmi]
            }
          }}
        end

        it do
          is_expected.to contain_file("/etc/prometheus/ipmi.yaml")
            .with_content(/collectors:\n *- "ipmi"\n *- "sel"\n *- "dcmi"/m)
        end
      end

      context "with no collectors" do
        let(:params) do
          { accounts: {
            "ipmi.example" => {
              "username" => "abc123",
              "password" => "!!secret!!",
              "collectors" => []
            }
          }}
        end

        it do
          is_expected.to contain_file("/etc/prometheus/ipmi.yaml")
            .with_content(/^ *collectors: \[]$/)
        end
      end

      context "with some sensor ids excluded" do
        let(:params) do
          { accounts: {
            "ipmi.example" => {
              "username" => "abc123",
              "password" => "!!secret!!",
              "exclude_sensor_ids" => [2, 32, 29]
            }
          }}
        end

        it do
          is_expected.to contain_file("/etc/prometheus/ipmi.yaml")
            .with_content(/ +exclude_sensor_ids:\n +- +2\n +- +32\n +- +29/m)
        end
      end

      context "with an empty list of sensor ids excluded" do
        let(:params) do
          { accounts: {
            "ipmi.example" => {
              "username" => "abc123",
              "password" => "!!secret!!",
              "exclude_sensor_ids" => []
            }
          }}
        end

        it do
          is_expected.to contain_file("/etc/prometheus/ipmi.yaml")
            .without_content(/exclude_sensor_ids/)
        end
      end

      context "with a basic LOM set" do
        let(:params) do
          { accounts: {
            "ipmi.example" => {
              "username" => "abc123",
              "password" => "!!secret!!"
            }
          }}
        end

        context "with a public IP address of 100.100.100.100" do
          let(:facts) do
            os_facts.merge(mlibrary_ip_addresses: {
              "public" => ["100.100.100.100"],
              "private" => [],
            })
          end

          it do
            expect(exported_resources).to contain_concat_fragment("prometheus ipmi scrape config #{facts[:hostname]}")
              .with_content(/^ +replacement: "100.100.100.100:9290"$/)
          end

          context "and a private IP address of 10.23.45.67" do
            let(:facts) do
              os_facts.merge(mlibrary_ip_addresses: {
                "public" => ["100.100.100.100"],
                "private" => ["10.23.45.67"],
              })
            end

            it do
              expect(exported_resources).to contain_concat_fragment("prometheus ipmi scrape config #{facts[:hostname]}")
                .with_content(/^ +replacement: "10.23.45.67:9290"$/)
            end
          end
        end

        context "with multiple public and private IP addresses" do
          let(:facts) do
            os_facts.merge(mlibrary_ip_addresses: {
              "public" => ["100.100.100.100", "100.200.200.200"],
              "private" => ["192.168.0.100", "10.23.45.67"],
            })
          end

          it "chooses the first private IP address" do
            expect(exported_resources).to contain_concat_fragment("prometheus ipmi scrape config #{facts[:hostname]}")
              .with_content(/^ +replacement: "192.168.0.100:9290"$/)
              .without_content(/100.100.100.100/)
              .without_content(/100.200.200.200/)
              .without_content(/10.23.45.67/)
          end
        end
      end
    end
  end
end
