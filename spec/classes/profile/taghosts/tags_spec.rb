# frozen_string_literal: true

# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require "spec_helper"

describe "nebula::profile::taghosts::tags" do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it { is_expected.to contain_nebula__taghosts__tag("no-datacenter") }
      it { is_expected.to contain_nebula__taghosts__tag("linux") }
      it { is_expected.to contain_nebula__taghosts__tag(facts[:os]["name"].downcase) }
      it { is_expected.to contain_nebula__taghosts__tag(facts[:os]["distro"]["codename"]) }
    end
  end
end
