# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require "spec_helper"

describe "fact_for" do
  let(:node_id) { "" }
  let(:fact_name) { "" }
  let(:fact_value) { "" }

  before(:each) do
    Puppet::Parser::Functions.newfunction(:puppetdb_query, type: :rvalue) { |_| raise "OVERRIDE ME!" }

    allow(scope).to receive(:function_puppetdb_query)
      .with([["from", "facts", ["extract", ["value"], ["and", ["=", "certname", node_id], ["=", "name", fact_name]]]]])
      .and_return([{"value" => fact_value}])
  end

  context "when my_node has datacenter my_datacenter" do
    let(:node_id) { "my_node" }
    let(:fact_name) { "datacenter" }
    let(:fact_value) { "my_datacenter" }

    it do
      expect(subject).to run.with_params("my_node", "datacenter")
        .and_return("my_datacenter")
    end
  end

  context "when node_a has networking.ip 10.1.2.3" do
    let(:node_id) { "node_a" }
    let(:fact_name) { "networking" }
    let(:fact_value) { {"ip" => "10.1.2.3"} }

    it do
      expect(subject).to run.with_params("node_a", "networking.ip")
        .and_return("10.1.2.3")
    end
  end
end
