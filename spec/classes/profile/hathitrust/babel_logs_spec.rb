# frozen_string_literal: true

# Copyright (c) 2023 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

require_relative '../../../support/contexts/with_htvm_setup'

describe 'nebula::profile::hathitrust::babel_logs' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      it { is_expected.to compile }

      it { is_expected.to contain_file('/var/log/babel').with_owner('nobody') }
      it { is_expected.to contain_file('/etc/alloy/babel.alloy').with_content(%r(/var/log/babel)) }
      it { is_expected.to contain_file('/etc/logrotate.d/babel').with_content(%r(/var/log/babel)) }
    end
  end
end
