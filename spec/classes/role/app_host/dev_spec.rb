# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::role::app_host::dev' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      [
        'base',
        'dns::standard',
        'metricbeat',
        'ruby',
      ].each do |profile|
        it { is_expected.to contain_class("nebula::profile::#{profile}") }
      end
    end
  end
end
