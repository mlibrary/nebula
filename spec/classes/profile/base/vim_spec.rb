# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::base::vim' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to contain_package('vim') }

      it do
        is_expected.to contain_file('/etc/vim/vimrc')
          .that_requires('Package[vim]')
      end

      [
        %r{^set mouse=$},
      ].each do |line|
        it { is_expected.to contain_file('/etc/vim/vimrc').with_content(line) }
      end

      it 'never enables any mouse usage of any kind' do
        is_expected.to contain_file('/etc/vim/vimrc').without_content(
          %r{^set mouse=.+$},
        )
      end
    end
  end
end
