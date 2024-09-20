# frozen_string_literal: true

# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::managed_known_hosts' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_concat('/etc/ssh/ssh_known_hosts') }

      context 'with static_host_keys set' do
        let(:params) { { static_host_keys: { 'myhost' => { 'ssh-ed25519' => 'abc123==' } } } }

        it do
          is_expected.to contain_concat_fragment('static known host myhost ssh-ed25519')
            .with_tag('known_host_public_keys')
            .with_target('/etc/ssh/ssh_known_hosts')
            .with_content("myhost ssh-ed25519 abc123==\n")
        end
      end
    end
  end
end
