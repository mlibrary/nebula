# frozen_string_literal: true

require "spec_helper"

describe "nebula::resolv_conf" do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it "removes resolvconf package if present" do
        expect(subject).to contain_package("resolvconf").with_ensure("absent")
      end

      it "contains expected resolv.conf file" do
        expect(subject).to contain_file("/etc/resolv.conf")
          .with_owner("root")
          .with_group("root")
          .with_mode("0644")
          .with_content(%r{^#.*puppet})
          .with_content(%r{^search searchpath\.default\.invalid$})
          .with_content(%r{^nameserver 5.5.5.5\nnameserver 4.4.4.4$})
      end

      context "with different nameservers" do
        let(:params) { {nameservers: ["3.3.3.3", "2.2.2.2", "1.1.1.1"]} }

        it do
          expect(subject).to contain_file("/etc/resolv.conf")
            .with_content(%r{^#.*puppet})
            .with_content(%r{^search searchpath\.default\.invalid$})
            .with_content(%r{^nameserver 3.3.3.3\nnameserver 2.2.2.2\nnameserver 1.1.1.1$})
        end
      end

      context "with searchpath set to []" do
        let(:params) { {searchpath: []} }

        it do
          expect(subject).to contain_file("/etc/resolv.conf")
            .with_content(%r{^#.*puppet})
            .without_content(%r{^search})
            .with_content(%r{^nameserver 5.5.5.5\nnameserver 4.4.4.4$})
        end
      end

      context "with custom file mode" do
        let(:params) { {mode: "0664"} }

        it do
          expect(subject).to contain_file("/etc/resolv.conf")
            .with_content(%r{^#.*puppet})
            .with_mode("0664")
        end
      end
    end
  end
end
