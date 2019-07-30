# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'lookup_role' do
  context 'when the role is my_role' do
    let(:hiera_config) { 'spec/fixtures/hiera/role_is_my_role_config.yaml' }

    it { is_expected.to run.and_return('my_role') }
  end

  context 'when the role is nebula::role::aws::auto' do
    let(:hiera_config) { 'spec/fixtures/hiera/role_is_aws_auto_config.yaml' }

    it { is_expected.to run.and_return('nebula::role::aws') }
  end
end
