# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nodes_for_class' do
  let(:class_title) { '' }
  let(:nodes) { [] }
  let!(:puppetdb_query) do
    MockFunction.new('puppetdb_query') do |f|
      f.stubbed
       .with(['from', 'resources', ['extract', ['certname'], ['=', 'title', class_title]]])
       .returns(nodes.map { |n| { 'certname' => n } })
    end
  end

  context 'when nodes node_a and node_b have the role my_role' do
    let(:class_title) { 'My_role' }
    let(:nodes) { %w[node_a node_b] }

    it do
      is_expected.to run.with_params('my_role')
                        .and_return(%w[node_a node_b])
    end
  end

  context 'when nodes node_1, node_2, and node_3 have the role nebula::default' do
    let(:class_title) { 'Nebula::Default' }
    let(:nodes) { %w[node_1 node_2 node_3] }

    it do
      is_expected.to run.with_params('nebula::default')
                        .and_return(%w[node_1 node_2 node_3])
    end
  end

  context 'it returns the nodes sorted by name' do
    let(:class_title) { 'My_role' }
    let(:nodes) { %w[node_b node_a node_z] }

    it do
      is_expected.to run.with_params('my_role')
                        .and_return(%w[node_a node_b node_z])
    end
  end
end
