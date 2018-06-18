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
        is_expected.to contain_class('resolv_conf').with_nameservers(
          ['5.5.5.5', '4.4.4.4'],
        ).with_searchpath(['searchpath.default.invalid'])
      end
    end
  end
end
