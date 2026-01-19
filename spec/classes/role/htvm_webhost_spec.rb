# frozen_string_literal: true

# Copyright (c) 2018, 2023 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require "spec_helper"

require_relative "../../support/contexts/with_htvm_setup"

describe "nebula::role::webhost::htvm" do
  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      include_context "with setup for htvm node", os_facts

      it do
        expect(subject).to contain_class("nebula::profile::shibboleth")
          .with(startup_timeout: 1800)
          .with(watchdog_minutes: "*/30")
      end

      it "contains nfs monitor concat fragments" do
        expect(subject).to contain_concat_fragment("monitor nfs /sdr")
          .with(tag: "monitor_config", content: {"nfs" => ["/sdr"]}.to_yaml)
        expect(subject).to contain_concat_fragment("monitor nfs /htapps")
          .with(tag: "monitor_config", content: {"nfs" => ["/htapps"]}.to_yaml)
      end

      context "with ens4" do
        let(:facts) do
          os_facts.deep_merge(
            networking: {
              "ip" => "1.2.3.123",
              "interfaces" => {"ens4" => {}}
            },
            is_virtual: true
          )
        end

        it { is_expected.to contain_mount("/htapps").that_requires("Exec[ifup ens4]") }
        it { is_expected.to contain_mount("/sdr").that_requires("Exec[ifup ens4]") }
      end

      it "contains expected nebula profiles" do
        expect(subject).to contain_class("nebula::profile::hathitrust::dependencies")
        expect(subject).to contain_class("nebula::profile::hathitrust::hosts")
        expect(subject).to contain_class("nebula::profile::hathitrust::mounts")
        expect(subject).to contain_class("nebula::profile::hathitrust::perl")
        expect(subject).to contain_class("nebula::profile::hathitrust::php")

        is_expected.to contain_class("nebula::profile::networking::firewall")

        is_expected.to contain_class("nebula::profile::krb5")
        is_expected.to contain_class("nebula::profile::afs")
        is_expected.to contain_class("nebula::profile::users")
      end

      if os == "debian-11-x86_64"
        it "contains expected php and apache packages" do
          is_expected.not_to contain_package("php5-common")
          is_expected.not_to contain_package("php5-dev")
          is_expected.to contain_package("libapache2-mod-shib")
          is_expected.not_to contain_package("libapache2-mod-shib2")
        end
      end

      it "contains expected groups" do
        # not specified explicitly as a usergroup, just brought in as part of 'all groups'
        is_expected.to contain_group("htprod")
        is_expected.to contain_group("htingest")
        # not specified explicitly - realized through Nebula::Usergroup[htprod]
        is_expected.to contain_user("htingest")
        is_expected.to contain_user("htweb")
      end
    end
  end
end
