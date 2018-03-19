# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::role::hathi::prep_app_host' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      [
        'base',
        'dns::smartconnect',
        'metricbeat',
        'ruby',
      ].each do |profile|
        it { is_expected.to contain_class("nebula::profile::#{profile}") }
      end
    end
  end
end
