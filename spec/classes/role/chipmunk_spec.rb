# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'
require_relative '../../support/contexts/with_mocked_nodes'

describe 'nebula::role::chipmunk' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      include_context 'with mocked query for nodes in other datacenters'

      let(:facts) { os_facts }
      let(:hiera_config) { 'spec/fixtures/hiera/chipmunk_config.yaml' }

      it { is_expected.to compile }

      if os == 'debian-9-x86_64'
        it { is_expected.to contain_file('/etc/pam.d/sshd-stretch') }
      end
    end
  end
end
