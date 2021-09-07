# frozen_string_literal: true

# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'
require_relative '../../../support/contexts/with_mocked_nodes'

describe 'nebula::profile::fulcrum::apache' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      include_context 'with mocked query for nodes in other datacenters'

      it { is_expected.to compile }

      it { is_expected.to contain_class('letsencrypt') }
      it { is_expected.to contain_class('apache') }
    end
  end
end
