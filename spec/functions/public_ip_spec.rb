# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'public_ip' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge(
          ipaddress: 'INVALID_DO_NOT_USE',
          hostname: 'INVALID_DO_NOT_USE',
          fqdn: 'INVALID_DO_NOT_USE',
        )
      end

      it { is_expected.to run.and_return(facts[:networking]['ip']) }
    end
  end
end
