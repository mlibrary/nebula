# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::dns::standard' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it do
        is_expected.to contain_class('nebula::resolv_conf').with_nameservers(
          ['5.5.5.5', '4.4.4.4'],
        ).with_searchpath(['searchpath.default.invalid'])
      end

      it 'removes resolvconf package if present' do
        is_expected.to contain_package('resolvconf').with_ensure('absent')
      end
      it 'contains expected resolv.conf file' do
        is_expected.to contain_file('/etc/resolv.conf')
          .with_content(/^#.*puppet/)
          .with_content(/^search searchpath\.default\.invalid$/)
          .with_content(/^nameserver 5.5.5.5$/)
          .with_content(/^nameserver 4.4.4.4$/)
      end
    end
  end
end
