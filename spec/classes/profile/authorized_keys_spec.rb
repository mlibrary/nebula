# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::authorized_keys' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      [
        %r{^ssh-rsa AAAAAAAAAAAA invalid_normal_admin@invalid\.default$},
        %r{^ssh-dsa BBBBBBBBBBBB invalid_special_admin@invalid\.special$},
      ].each do |line|
        it do
          is_expected.to contain_file('/etc/secretkeys/invalid.default')
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
