# frozen_string_literal: true

# Copyright (c) 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::fulcrum::logrotate' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it { is_expected.to contain_class('Nebula::Profile::Logrotate') }

      it do
        is_expected.to contain_logrotate__rule('fulcrum')
          .with_path('/fulcrum/app/shared/log/*.log')
          .with_rotate(7)
          .with_rotate_every('day')
          .with_missingok(true)
          .with_compress(true)
          .with_ifempty(false)
          .with_delaycompress(true)
          .with_copytruncate(true)
      end
    end
  end
end
