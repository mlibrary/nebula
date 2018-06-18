# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::base::environment' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to contain_file('/etc/profile.d/lit-cs.sh') }

      context 'when given a couple vars' do
        let(:params) { { vars: { 'a' => 'hello', 'b' => 'goodbye' } } }

        it do
          is_expected.to contain_file('/etc/profile.d/lit-cs.sh')
            .with_content(%r{^\s*export a=hello$})
            .with_content(%r{^\s*export b=goodbye$})
        end
      end
    end
  end
end
