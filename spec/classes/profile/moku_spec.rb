# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::moku' do
  on_supported_os.each do |os, os_facts|
    # set up hiera
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:hiera_config) { 'spec/fixtures/hiera/named_instances_config.yaml' }

      it { is_expected.to contain_nebula__named_instance('minimal-instance') }
      it { is_expected.to contain_nebula__named_instance('first-instance') }
    end
  end
end
