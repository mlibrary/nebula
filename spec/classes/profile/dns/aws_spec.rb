# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::dns::aws' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.not_to contain_class('resolv_conf')   }
      it { is_expected.to contain_exec('restart_networking') }
      it { is_expected.to contain_file_line('domain_name') }
      # search_domain should match content of nebula::resolv_conf::searchpath
      it do
        is_expected.to contain_file_line('search_domain').with_line(
          'supersede domain-search "searchpath.default.invalid";',
        )
      end
    end
  end
end
