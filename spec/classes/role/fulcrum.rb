# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::role::fulcrum' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      
      it { is_expected.to compile }

    end
  end
end
