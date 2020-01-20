# frozen_string_literal: true

# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::cifs_mount' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:hiera_config) { 'spec/fixtures/hiera/cifs_config.yaml' }
      let(:title) { '/mnt/default_invalid' }
      let(:params) do
        {
          remote_target: '//default.invalid/path',
          uid: 'root',
          gid: 'root',
          user: 'default_cifs_user',
        }
      end

      it { is_expected.to compile }

      it { is_expected.to contain_package('cifs-utils').with_ensure('present') }
      it { is_expected.to contain_file(title).with_ensure('directory') }
      it { is_expected.not_to contain_file('/etc/default/an_unused_user-credentials') }

      it do
        is_expected.to contain_file('/etc/default/default_cifs_user-credentials')
          .with_source('puppet:///cifs-credentials/default_cifs_user-credentials')
          .with_mode('0400')
          .with_owner('root')
          .with_group('root')
      end

      it do
        is_expected.to contain_mount(title)
          .with_ensure('mounted')
          .with_device('//default.invalid/path')
          .with_fstype('cifs')
          .with_options('credentials=/etc/default/default_cifs_user-credentials,uid=root,gid=root,file_mode=0644,dir_mode=0755,vers=2.1')
          .that_requires('Package[cifs-utils]')
      end

      context 'when remote_target is set to "//cool_store.com/wow"' do
        let(:params) do
          super().merge(remote_target: '//cool_store.com/wow')
        end

        it { is_expected.to contain_mount(title).with_device('//cool_store.com/wow') }
      end

      context 'when uid is set to "my_app"' do
        let(:params) do
          super().merge(uid: 'my_app')
        end

        it { is_expected.to contain_mount(title).with_options(%r{,uid=my_app,}) }
      end

      context 'when gid is set to "users"' do
        let(:params) do
          super().merge(gid: 'users')
        end

        it { is_expected.to contain_mount(title).with_options(%r{,gid=users,}) }
      end

      context 'when user is set to "example_cifs_user"' do
        let(:params) do
          super().merge(user: 'example_cifs_user')
        end

        it { is_expected.to contain_file('/etc/default/example_cifs_user-credentials') }
        it { is_expected.to contain_mount(title).with_options(%r{^credentials=/etc/default/example_cifs_user-credentials,}) }
      end

      context 'when user is set to a user not in nebula::cifs::credentials::users' do
        let(:params) do
          super().merge(user: 'undefined_cifs_user')
        end

        it { is_expected.not_to compile }
      end

      context 'when another cifs_mount is defined with the same user' do
        let(:pre_condition) do
          <<~EOF
            nebula::cifs_mount { '/mnt/another_mount':
              remote_target => '//another.invalid/another',
              uid           => 'root',
              gid           => 'root',
              user          => 'default_cifs_user',
            }
          EOF
        end

        it { is_expected.to compile }
      end
    end
  end
end
