# frozen_string_literal: true

# Copyright (c) 2023 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

require_relative '../../../support/contexts/with_htvm_setup'

describe 'nebula::profile::hathitrust::php' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      include_context 'with setup for htvm node', os_facts

      it { is_expected.to compile }
      it { is_expected.to contain_php__extension('File_MARC').with_provider('pear') }
    end
  end
end
