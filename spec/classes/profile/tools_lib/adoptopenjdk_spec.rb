# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::tools_lib::adoptopenjdk' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it 'installs OpenJDK 8 from AdoptOpenJDK' do
        is_expected.to contain_java__oracle('jdk8')
      end
    end
  end
end
