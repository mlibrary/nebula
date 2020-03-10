# frozen_string_literal: true

# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::root_ssh_private_keys' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:hiera_config) { 'spec/fixtures/hiera/ssh_keys_config.yaml' }
      let(:facts) { os_facts }

      it do
        is_expected.to contain_file('/var/local/ssh')
          .with_ensure('directory')
      end

      it do
        is_expected.to contain_file('/var/local/ssh/invalid_normal_admin')
          .with_ensure('directory')
          .with_mode('0700')
          .with_owner('invalid_normal_admin')
          .that_requires('File[/var/local/ssh]')
      end

      it do
        is_expected.to contain_file('/var/local/ssh/invalid_normal_admin/id_ecdsa')
          .with_mode('0600')
          .with_owner('invalid_normal_admin')
          .with_source('puppet:///root-ssh-private-keys/invalid_normal_admin/id_ecdsa')
          .that_requires('File[/var/local/ssh/invalid_normal_admin]')
      end

      it do
        is_expected.to contain_file('/var/local/ssh/invalid_normal_admin/id_ecdsa.pub')
          .with_mode('0644')
          .with_owner('invalid_normal_admin')
          .with_source('puppet:///root-ssh-private-keys/invalid_normal_admin/id_ecdsa.pub')
          .that_requires('File[/var/local/ssh/invalid_normal_admin]')
      end

      it do
        is_expected.to contain_file('/var/local/ssh/invalid_special_admin')
          .with_ensure('directory')
          .with_mode('0700')
          .with_owner('invalid_special_admin')
          .that_requires('File[/var/local/ssh]')
      end

      it do
        is_expected.to contain_file('/var/local/ssh/invalid_special_admin/id_ecdsa')
          .with_mode('0600')
          .with_owner('invalid_special_admin')
          .with_source('puppet:///root-ssh-private-keys/invalid_special_admin/id_ecdsa')
          .that_requires('File[/var/local/ssh/invalid_special_admin]')
      end

      it do
        is_expected.to contain_file('/var/local/ssh/invalid_special_admin/id_ecdsa.pub')
          .with_mode('0644')
          .with_owner('invalid_special_admin')
          .with_source('puppet:///root-ssh-private-keys/invalid_special_admin/id_ecdsa.pub')
          .that_requires('File[/var/local/ssh/invalid_special_admin]')
      end
    end
  end
end
