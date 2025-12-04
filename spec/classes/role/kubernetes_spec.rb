# frozen_string_literal: true

# Copyright (c) 2019-2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require "spec_helper"

%w[primary backup].each do |tier|
  describe "nebula::role::kubernetes::#{tier}_gateway" do
    on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
      next if os == "debian-8-x86_64"

      context "on #{os}" do
        let(:hiera_config) { "spec/fixtures/hiera/kubernetes/first_cluster_config.yaml" }
        let(:facts) do
          my_facts = os_facts.deep_merge(
            networking: {
              "interfaces" => {
                "ens4" => {
                  "ip" => "10.123.234.5"
                }
              },
              "ip" => "10.123.234.5",
              "primary" => "ens4"
            }
          )
          my_facts[:networking]["interfaces"].delete("eth0")
          my_facts
        end

        it { is_expected.to contain_class("Nebula::Profile::Ntp") }

        it { is_expected.to contain_service("haproxy").that_notifies("Service[keepalived]") }
      end
    end
  end
end

%w[controller etcd worker].each do |role|
  describe "nebula::role::kubernetes::#{role}" do
    on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
      next if os == "debian-8-x86_64"

      context "on #{os}" do
        let(:hiera_config) { "spec/fixtures/hiera/kubernetes/first_cluster_config.yaml" }
        let(:facts) do
          my_facts = os_facts.deep_merge(
            networking: {
              "interfaces" => {
                "ens4" => {
                  "ip" => "10.123.234.5"
                }
              },
              "ip" => "10.123.234.5",
              "primary" => "ens4"
            }
          )
          my_facts[:networking]["interfaces"].delete("eth0")
          my_facts
        end

        it { is_expected.to contain_class("Nebula::Profile::Ntp") }

        it "does not configure firewall" do
          is_expected.not_to contain_resources("firewall")
          is_expected.not_to contain_class("nebula::profile::networking::firewall")
        end
        it "does not configure firewallchains" do
          is_expected.not_to contain_firewallchain("INPUT:filter:IPv4")
          is_expected.not_to contain_firewallchain("OUTPUT:filter:IPv4")
          is_expected.not_to contain_firewallchain("FORWARD:filter:IPv4")
        end

        case role
        when "etcd"
          it do
            expect(exported_resources).to contain_concat_fragment("cluster pki for #{facts[:networking]["hostname"]}")
              .with_tag("first_cluster_pki_generation")
              .with_target("/var/local/generate_pki.sh")
              .with_order("02")
              .with_content("ETCD_NODES=(\"${ETCD_NODES[@]}\" \"#{facts[:networking]["hostname"]}/#{facts[:networking]["ip"]}\")\n")
          end
        when "controller"
          it do
            expect(exported_resources).to contain_concat_fragment("cluster pki for #{facts[:networking]["hostname"]}")
              .with_tag("first_cluster_pki_generation")
              .with_target("/var/local/generate_pki.sh")
              .with_order("02")
              .with_content("KUBE_CONTROLLERS=(\"${KUBE_CONTROLLERS[@]}\" \"#{facts[:networking]["hostname"]}/#{facts[:networking]["ip"]}\")\n")
          end
        when "worker"
          it do
            expect(exported_resources).to contain_concat_fragment("cluster pki for #{facts[:networking]["hostname"]}")
              .with_tag("first_cluster_pki_generation")
              .with_target("/var/local/generate_pki.sh")
              .with_order("02")
              .with_content("KUBE_WORKERS=(\"${KUBE_WORKERS[@]}\" \"#{facts[:networking]["hostname"]}/#{facts[:networking]["ip"]}\")\n")
          end

          it { is_expected.to contain_package("lvm2") }
        end
      end
    end
  end
end
