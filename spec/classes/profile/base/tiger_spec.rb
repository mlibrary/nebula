# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::base::tiger' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it do
        is_expected.to contain_file_line('tiger dormant limit').with(
          path: '/etc/tiger/tigerrc',
          line: 'Tiger_Dormant_Limit=0',
          match: '^Tiger_Dormant_Limit',
        )
      end
    end
  end
end
