# frozen_string_literal: true

# Copyright (c) 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::alma_integrations' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it { is_expected.to contain_user('alma').with_home('/var/lib/alma') }

      it do
        is_expected.to contain_nebula__file__ssh_keys('/var/lib/alma/.ssh/authorized_keys')
          .with(secret: true)
          .with(owner: 'alma')
          .with(group: 'alma')
          .with(keys: [])
      end

      describe 'takes keys from hiera' do
        let(:hiera_config) { 'spec/fixtures/hiera/alma_config.yaml' }

        it do
          is_expected.to contain_nebula__file__ssh_keys('/var/lib/alma/.ssh/authorized_keys')
            .with(secret: true)
            .with(owner: 'alma')
            .with(group: 'alma')
            .with(keys: [{
                    'type' => 'ssh-rsa',
                    'data' => 'abcdefgh',
                    'comment' => 'sshuser@host',
                  }])
        end
      end
    end
  end
end
