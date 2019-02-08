# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

require_relative '../../support/contexts/with_htvm_setup'

describe 'nebula::role::webhost::htvm::prod' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      include_context 'with setup for htvm node', os_facts
      it { is_expected.to compile }

      it 'exports a haproxy::binding resource for hathitrust' do
        expect(exported_resources).to contain_nebula__haproxy__binding('thisnode hathitrust')
          .with(service: 'hathitrust', datacenter: 'somedc')
      end
    end
  end
end
