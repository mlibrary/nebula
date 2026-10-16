# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require "spec_helper"

require_relative "../../support/contexts/with_htvm_setup"

describe "nebula::role::webhost::htvm::prod" do
  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      include_context "with setup for htvm node", os_facts.merge(mlibrary_ip_addresses: {"public" => [os_facts[:networking]["ip"]], "private" => ["10.20.40.80"]})

      it "exports a haproxy::binding resource for hathitrust" do
        expect(exported_resources).to contain_nebula__haproxy__binding("thisnode hathitrust")
          .with(service: "hathitrust", datacenter: "somedc")
      end

      it "exports a haproxy::binding resource for private hathitrust" do
        expect(exported_resources).to contain_nebula__haproxy__binding("thisnode private hathitrust")
          .with(service: "hathitrust", datacenter: "somedc", organization: "ht", ipaddress: "10.20.40.80")
      end
    end
  end
end
