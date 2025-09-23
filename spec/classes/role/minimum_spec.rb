# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require "spec_helper"

describe "nebula::role::minimum" do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to contain_class("nebula::profile::networking::firewall") }

      context "manage_firewall false" do
        let(:params) do
          {manage_firewall: false}
        end

        it { is_expected.not_to contain_class("nebula::profile::networking::firewall") }
        it { is_expected.to contain_package("netfilter-persistent").with_ensure("purged") }
        it { is_expected.to contain_package("iptables-persistent").with_ensure("purged") }
      end
    end
  end
end
