# frozen_string_literal: true

# Copyright (c) 2026 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require "spec_helper"

describe "nebula::profile::quod::prod::metrics" do
  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it do
        expect(subject).to contain_service("mtail")
          .with_ensure("running")
          .with_enable(true)
      end

      it "exports the target to the datacenter's service discovery" do
        expect(exported_resources).to contain_concat_fragment("prometheus quod scrape config #{facts[:networking]["hostname"]}")
          .with_tag("mydatacenter_prometheus_quod_service_list")
          .with_target("/etc/prometheus/quod.yml")
      end
    end
  end
end
