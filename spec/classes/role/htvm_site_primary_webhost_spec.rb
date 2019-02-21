# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

require_relative '../../support/contexts/with_htvm_setup'

describe 'nebula::role::webhost::htvm::site_primary' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      include_context 'with setup for htvm node', os_facts
      it { is_expected.to compile }

      # includes cron jobs that run at each site
      it { is_expected.to contain_class('nebula::profile::hathitrust::cron::mdp_misc') }
      # sets cache parameters
    end
  end
end
