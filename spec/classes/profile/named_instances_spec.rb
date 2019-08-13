# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::named_instances' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      describe 'puma wrapper' do
        let(:klass) { 'nebula::profile::named_instances::puma_wrapper' }

        # defaults from hiera
        it { is_expected.to contain_class(klass).with(path: '/l/local/bin/profile_puma_wrap') }
        it { is_expected.to contain_class(klass).with(rbenv_root: '/opt/rbenv') }
        it { is_expected.to contain_class(klass).with(puma_config: 'config/fauxpaas_puma.rb') }
        it { is_expected.to contain_package('rsync') }
      end
    end
  end
end
