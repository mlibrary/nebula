# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::base::apt' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it do
        is_expected.to contain_file('/etc/apt/apt.conf.d/99force-ipv4')
          .with_content(%r{^Acquire::ForceIPv4 "true";$})
      end

      it do
        is_expected.to contain_cron('apt-get update')
          .with_command('/usr/bin/apt-get update -qq')
          .with_hour('1')
          .with_minute('0')
      end
    end
  end
end
