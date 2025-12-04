# frozen_string_literal: true

# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require "spec_helper"

describe "nebula::profile::taghosts::index" do
  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it { is_expected.to contain_concat("/var/lib/ae/active-servers") }
      it { is_expected.to contain_file("/usr/local/bin/taghosts") }
      it { is_expected.to contain_file("/usr/local/bin/exechosts") }

      context "with a static server" do
        let(:params) { {static_hosts: {"myhost.default.invalid" => %w[abc def ghi]}} }

        it { is_expected.to compile }
        it { is_expected.to contain_concat__fragment("taghosts myhost.default.invalid 000") }
        it { is_expected.to contain_concat__fragment("taghosts myhost.default.invalid 001 abc") }
        it { is_expected.to contain_concat__fragment("taghosts myhost.default.invalid 002 def") }
        it { is_expected.to contain_concat__fragment("taghosts myhost.default.invalid 003 ghi") }
        it { is_expected.to contain_concat__fragment("taghosts myhost.default.invalid 999") }
      end
    end
  end
end
