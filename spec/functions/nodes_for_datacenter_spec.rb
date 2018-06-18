# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nodes_for_datacenter' do
  let(:datacenter) { '' }
  let(:nodes) { [] }
  let!(:puppetdb_query) do
    MockFunction.new('puppetdb_query') do |f|
      f.stubbed
       .with(['from', 'facts', ['extract', ['certname'], ['and', ['=', 'name', 'datacenter'], ['=', 'value', datacenter]]]])
       .returns(nodes.map { |n| { 'certname' => n } })
    end
  end

  context 'when nodes node_a and node_b are in my_datacenter' do
    let(:datacenter) { 'my_datacenter' }
    let(:nodes) { %w[node_a node_b] }

    it do
      is_expected.to run.with_params('my_datacenter')
                        .and_return(%w[node_a node_b])
    end
  end

  context 'when nodes node_c and node_d are in another_datacenter' do
    let(:datacenter) { 'another_datacenter' }
    let(:nodes) { %w[node_c node_d] }

    it do
      is_expected.to run.with_params('another_datacenter')
                        .and_return(%w[node_c node_d])
    end
  end
end
