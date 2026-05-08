# frozen_string_literal: true

# Copyright (c) 2020, 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require "spec_helper"

describe "nebula::profile::kubernetes::dns_server" do
  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      context "with cluster set to first_cluster" do
        let(:hiera_config) { "spec/fixtures/hiera/kubernetes/first_cluster_config.yaml" }
        let(:facts) do
          os_facts.deep_merge(
            networking: {
              interfaces: {
                ens4: {
                  ip: "10.123.234.5"
                }
              },
              ip: "10.123.234.5"
            }
          )
        end

        it { is_expected.to compile }

        it { is_expected.to contain_package("dnsmasq") }
        it { is_expected.to contain_service("dnsmasq").that_requires("Package[dnsmasq]") }

        it { is_expected.to contain_firewall("200 Nameserver (TCP)").with_proto("tcp") }
        it { is_expected.to contain_firewall("200 Nameserver (UDP)").with_proto("udp") }

        %w[TCP UDP].each do |proto|
          it do
            expect(subject).to contain_firewall("200 Nameserver (#{proto})")
              .with_dport(53)
              .with_source("172.28.0.0/14")
              .with_state("NEW")
              .with_jump("accept")
          end
        end

        it { is_expected.to contain_concat("/etc/hosts").that_notifies("Service[dnsmasq]") }

        it do
          expect(subject).to contain_concat_fragment("/etc/hosts ipv4 localhost")
            .with_target("/etc/hosts")
            .with_order("01")
            .with_content("127.0.0.1 localhost\n")
        end

        it do
          expect(subject).to contain_concat_fragment("/etc/hosts ipv4 etcd-all")
            .with_target("/etc/hosts")
            .with_order("02")
            .with_content("172.16.0.6 etcd.first.cluster etcd\n")
        end

        it do
          expect(subject).to contain_concat_fragment("/etc/hosts ipv4 kube-api")
            .with_target("/etc/hosts")
            .with_order("03")
            .with_content("172.16.0.7 kube-api.first.cluster kube-api\n")
        end

        it do
          expect(subject).to contain_concat_fragment("/etc/hosts ipv6 localhost")
            .with_target("/etc/hosts")
            .with_content("::1 localhost ip6-localhost ip6-loopback\n")
        end

        it do
          expect(subject).to contain_concat_fragment("/etc/hosts static entries")
            .with_target("/etc/hosts")
            .with_content("172.16.0.232 example.com www-232.example.com\n172.16.0.233 sql.example.com db-233.example.com\n")
        end

        it do
          expect(subject).to contain_file("/etc/dnsmasq.d/smartconnect")
            .with_content("server=/sc.default.invalid/192.0.2.7\n")
        end

        it do
          expect(subject).to contain_file("/etc/dnsmasq.d/local_domain")
            .with_content("local=/first.cluster/\n")
        end

        it do
          expect(subject).to contain_file("/etc/default/dnsmasq")
            .with_content("CONFIG_DIR=/etc/dnsmasq.d,.dpkg-dist,.dpkg-old,.dpkg-new\nIGNORE_RESOLVCONF=yes\n")
        end

        it do
          expect(subject).to contain_exec("divert /etc/default/dnsmasq")
            .with_creates("/etc/default/dnsmasq.dist")
            .with_command("/usr/bin/dpkg-divert --rename --divert /etc/default/dnsmasq.dist --add /etc/default/dnsmasq")
        end

        it do
          expect(subject).to contain_exec("divert /etc/default/dnsmasq")
            .that_notifies("Service[dnsmasq]")
            .that_requires("Package[dnsmasq]")
            .that_comes_before("File[/etc/default/dnsmasq]")
        end

        it do
          expect(subject).to contain_concat_fragment("/etc/hosts ipv6 debian")
            .with_target("/etc/hosts")
            .with_content("ff02::1 ip6-allnodes\nff02::2 ip6-allrouters\n")
        end
      end

      context "with cluster set to second_cluster" do
        let(:hiera_config) { "spec/fixtures/hiera/kubernetes/second_cluster_config.yaml" }
        let(:facts) { os_facts }

        it { is_expected.to compile }

        it { is_expected.not_to contain_file("/etc/dnsmasq.d/smartconnect") }

        it do
          expect(subject).to contain_file("/etc/dnsmasq.d/local_domain")
            .with_content("local=/second.cluster/\n")
        end
      end
    end
  end
end
