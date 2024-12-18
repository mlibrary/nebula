# frozen_string_literal: true

require "spec_helper"

describe "nodes_for_class" do
  let(:class_title) { "" }
  let(:nodes) { [] }

  before(:each) do
    Puppet::Parser::Functions.newfunction(:puppetdb_query, type: :rvalue) { |_| raise "OVERRIDE ME!" }

    allow(scope).to receive(:function_puppetdb_query)
      .with([["from", "resources", ["extract", ["certname"], ["=", "title", class_title]]]])
      .and_return(nodes.map { |n| {"certname" => n} })
  end

  context "when nodes node_a and node_b have the role my_role" do
    let(:class_title) { "My_role" }
    let(:nodes) { %w[node_a node_b] }

    it do
      expect(subject).to run.with_params("my_role")
        .and_return(%w[node_a node_b])
    end
  end

  context "when nodes node_1, node_2, and node_3 have the role nebula::default" do
    let(:class_title) { "Nebula::Default" }
    let(:nodes) { %w[node_1 node_2 node_3] }

    it do
      expect(subject).to run.with_params("nebula::default")
        .and_return(%w[node_1 node_2 node_3])
    end
  end

  context "when nodes node_b, node_a, and node_z have the role My_role" do
    let(:class_title) { "My_role" }
    let(:nodes) { %w[node_b node_a node_z] }

    it "returns the nodes sorted by name" do
      expect(subject).to run.with_params("my_role")
        .and_return(%w[node_a node_b node_z])
    end
  end
end
