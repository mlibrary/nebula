# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require "spec_helper"

describe "nebula::profile::networking" do
  def contain_network_class(name)
    contain_class("nebula::profile::networking::#{name}")
  end

  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context "when bridge==false" do
        let(:params) { {bridge: false} }

        it { is_expected.to contain_network_class("sysctl").with_bridge(false) }
      end

      context "when bridge==true" do
        let(:params) { {bridge: true} }

        it { is_expected.to contain_network_class("sysctl").with_bridge(true) }
      end
    end
  end
end
