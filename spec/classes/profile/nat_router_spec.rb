# frozen_string_literal: true

# Copyright (c) 2026 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require "spec_helper"

describe "nebula::profile::nat_router" do
  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) { {lan_cidr: "10.0.0.0/8", public_ip_address: "1.2.3.4"} }

      it { is_expected.to compile }

      it do
        is_expected.to contain_file("/etc/sysctl.d/router.conf")
          .with_content(/^net\.ipv4\.ip_forward = 1$/)
          .that_notifies("Service[procps]")
      end

      it do
        is_expected.to contain_firewall("001 leave internal requests alone")
          .with_table("nat")
          .with_chain("POSTROUTING")
          .with_proto("all")
          .with_jump("accept")
          .with_source("10.0.0.0/8")
          .with_destination("10.0.0.0/8")
      end

      it do
        is_expected.to contain_firewall("002 translate the source address on external requests")
          .with_table("nat")
          .with_chain("POSTROUTING")
          .with_proto("all")
          .with_jump("SNAT")
          .with_source("10.0.0.0/8")
          .with_tosource("1.2.3.4")
      end

      context "when the lan_cidr is set to 192.168.0.0/16" do
        let(:params) { super().merge(lan_cidr: "192.168.0.0/16") }

        it do
          is_expected.to contain_firewall("001 leave internal requests alone")
            .with_table("nat")
            .with_chain("POSTROUTING")
            .with_proto("all")
            .with_jump("accept")
            .with_source("192.168.0.0/16")
            .with_destination("192.168.0.0/16")
        end

        it do
          is_expected.to contain_firewall("002 translate the source address on external requests")
            .with_table("nat")
            .with_chain("POSTROUTING")
            .with_proto("all")
            .with_jump("SNAT")
            .with_source("192.168.0.0/16")
            .with_tosource("1.2.3.4")
        end
      end

      context "when the public_ip_address is set to 2.4.6.8" do
        let(:params) { super().merge(public_ip_address: "2.4.6.8") }

        it do
          is_expected.to contain_firewall("002 translate the source address on external requests")
            .with_table("nat")
            .with_chain("POSTROUTING")
            .with_proto("all")
            .with_jump("SNAT")
            .with_source("10.0.0.0/8")
            .with_tosource("2.4.6.8")
        end
      end
    end
  end
end
