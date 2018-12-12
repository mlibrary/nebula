# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::authorized_keys' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:hiera_config) { 'spec/fixtures/hiera/ssh_keys_config.yaml' }

      [
        %r{^ssh-rsa AAAAAAAAAAAA invalid_normal_admin@default\.invalid$},
        %r{^ssh-dsa BBBBBBBBBBBB invalid_special_admin@special\.invalid$},
      ].each do |line|
        it do
          is_expected.to contain_file('/etc/secretkeys/default.invalid')
            .with_content(line)
        end
      end

      it do
        is_expected.to contain_file('/etc/secretkeys').with(
          ensure: 'directory',
          mode: '0700',
        )
      end
    end
  end
end
