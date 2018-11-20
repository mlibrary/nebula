# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::hathitrust::imgsrv' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to contain_service('imgsrv') }

      it { is_expected.to contain_file('/usr/local/bin/startup_imgsrv').with_content(%r{^SDRROOT=/sdrroot$}) }
      it { is_expected.to contain_file('/usr/local/bin/startup_imgsrv').with_content(%r{^NPROC=10$}) }
      it { is_expected.to contain_file('/usr/local/bin/startup_imgsrv').with_content(%r{^BIND=127.0.0.1:31028}) }

      it { is_expected.to contain_file('/etc/systemd/system/imgsrv.service').with_content(%r{ExecStart=/usr/local/bin/startup_imgsrv}) }
    end
  end
end
