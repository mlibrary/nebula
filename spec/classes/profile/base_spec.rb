# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require "spec_helper"

describe "nebula::profile::base" do
  def contain_base_class(name)
    contain_class("nebula::profile::base::#{name}")
  end

  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:fqdn) { facts[:fqdn] }

      it { is_expected.to contain_service("puppet").with_ensure("running") }
      it { is_expected.to contain_service("puppet").with_enable(true) }

      case os
      when %r{^debian}, %r{^ubuntu}
        it { is_expected.to contain_package("zstd") }
        it { is_expected.to contain_package("dbus") }
        it { is_expected.to contain_package("dkms") }

        it do
          expect(subject).to contain_file("/etc/localtime")
            .with_ensure("link")
            .with_target("/usr/share/zoneinfo/US/Eastern")
        end

        it do
          expect(subject).to contain_file("/etc/timezone")
            .with_content("US/Eastern\n")
        end

        context "with timezone set to America/Detroit" do
          let(:params) { {timezone: "America/Detroit"} }

          it do
            expect(subject).to contain_file("/etc/localtime")
              .with_ensure("link")
              .with_target("/usr/share/zoneinfo/America/Detroit")
          end

          it do
            expect(subject).to contain_file("/etc/timezone")
              .with_content("America/Detroit\n")
          end
        end

        it do
          expect(subject).to contain_file("/etc/hostname")
            .with_content("#{fqdn}\n")
            .that_notifies("Exec[/bin/hostname #{fqdn}]")
        end

        it do
          expect(subject).to contain_exec("/bin/hostname #{fqdn}")
            .with_refreshonly(true)
        end

        it do
          expect(subject).to contain_file("/etc/motd")
            .with_content(%r{contact us at contact@default\.invalid\.$})
            .with_content(%r{administered by Default Incorrect Dept\.$})
        end

        context "when given a contact_email of the_dean@umich.edu" do
          let(:params) { {contact_email: "the_dean@umich.edu"} }

          it do
            expect(subject).to contain_file("/etc/motd")
              .with_content(%r{contact us at the_dean@umich\.edu\.$})
          end
        end

        context "when given a sysadmin_dept of The Cool Team" do
          let(:params) { {sysadmin_dept: "The Cool Team"} }

          it do
            expect(subject).to contain_file("/etc/motd")
              .with_content(%r{administered by The Cool Team\.$})
          end
        end
      end

      case os
      when %r{^ubuntu}
        it "disables ubuntu motd spam" do
          expect(subject).to contain_file("/var/lib/update-notifier/hide-esm-in-motd")
        end
      else
        it "does not manage ubuntu specific motd files" do
          expect(subject).not_to contain_file("/var/lib/update-notifier/hide-esm-in-motd")
        end
      end

      context "when on an HP machine" do
        let(:facts) do
          super().merge("dmi" => {"manufacturer" => "HP"})
        end

        it do
          expect(subject).to contain_kmod__blacklist("hpwdt").with(
            file: "/etc/modprobe.d/hpwdt-blacklist.conf"
          )
        end

        it do
          expect(subject).to contain_kmod__blacklist("acpi_power_meter").with(
            file: "/etc/modprobe.d/acpi_power_meter-blacklist.conf"
          )
        end
      end

      context "when on a vm" do
        let(:facts) do
          super().merge("is_virtual" => true)
        end

        it { is_expected.not_to contain_package("vlan") }
      end

      context "when not on a vm" do
        let(:facts) do
          super().merge("is_virtual" => false)
        end

        it { is_expected.to contain_package("vlan") }
      end

      context "when on an HPE machine" do
        let(:facts) do
          super().merge("dmi" => {"manufacturer" => "HPE"})
        end

        it do
          expect(subject).to contain_kmod__blacklist("hpwdt").with(
            file: "/etc/modprobe.d/hpwdt-blacklist.conf"
          )
        end

        it do
          expect(subject).to contain_kmod__blacklist("acpi_power_meter").with(
            file: "/etc/modprobe.d/acpi_power_meter-blacklist.conf"
          )
        end

        it { is_expected.to contain_package("ssacli") }
      end

      context "when on an Dell machine" do
        let(:facts) do
          super().merge("dmi" => {"manufacturer" => "Dell Inc."})
        end

        it { is_expected.not_to contain_kmod__blacklist("hpwdt") }
        it { is_expected.not_to contain_kmod__blacklist("acpi_power_meter") }
      end

      it { is_expected.not_to contain_package("i40e-dkms") }

      context "with an Intel X710 network card" do
        let(:facts) do
          super().merge("network_cards" => ["Intel Corporation Ethernet Controller X710 for 10GbE SFP+ (rev 01)"])
        end

        it { is_expected.not_to contain_package("i40e-dkms") }
      end
    end
  end
end
