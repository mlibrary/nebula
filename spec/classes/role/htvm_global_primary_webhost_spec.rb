# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

require_relative '../../support/contexts/with_htvm_setup'

describe 'nebula::role::webhost::htvm::global_primary' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      include_context 'with setup for htvm node', os_facts
      it { is_expected.to compile }

      # includes cron jobs that run on only one node in cluster
      it { is_expected.to contain_class('nebula::profile::hathitrust::cron::catalog') }
      it { is_expected.to contain_class('nebula::role::webhost::htvm::site_primary') }

      it do
        is_expected.to contain_cron('wordpress cron')
          .with(user: 'nobody',
                command: %r{.*wp-cron.php.*},
                minute: 0)
      end
    end
  end
end
