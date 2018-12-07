# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'inverted_hashlist' do
  let(:hiera_config) { 'spec/fixtures/hiera/inverted_hashlist_config.yaml' }

  [
    [{}, {}],
    [{ 'a' => [] }, {}],
    [{ 'a' => %w[1] }, { '1' => %w[a] }],
    [{ 'a' => %w[1 2] }, { '1' => %w[a], '2' => %w[a] }],
    [{ 'a' => %w[1], 'b' => %w[2] }, { '1' => %w[a], '2' => %w[b] }],
  ].each do |input, output|
    it { is_expected.to run.with_params(input).and_return(output) }
  end

  it do
    result = subject.execute('a' => %w[1], 'b' => %w[1])
    expect(result.keys).to contain_exactly('1')
    expect(result['1']).to contain_exactly('a', 'b')
  end

  it do
    result = subject.execute('a' => %w[1 2], 'b' => %w[2])
    expect(result.keys).to contain_exactly('1', '2')
    expect(result['1']).to contain_exactly('a')
    expect(result['2']).to contain_exactly('a', 'b')
  end

  it do
    result = subject.execute('example_hash')
    expect(result.keys).to contain_exactly('value_1', 'value_2', 'value_3')
    expect(result['value_1']).to contain_exactly('key_1')
    expect(result['value_2']).to contain_exactly('key_1', 'key_2')
    expect(result['value_3']).to contain_exactly('key_2')
  end
end
