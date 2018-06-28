# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::file::ssh_keys' do
  let(:title) { '/opt/keys' }
  let(:params) do
    {}
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'when called /opt/keys' do
        it do
          is_expected.to contain_file('/opt/keys')
            .without_content(%r{^[^#]})
        end

        it { is_expected.not_to contain_file('/opt') }
      end

      context 'when called /etc/keys' do
        let(:title) { '/etc/keys' }

        it { is_expected.to contain_file('/etc/keys') }
      end

      context 'when given a key' do
        let(:params) do
          {
            keys: [
              {
                type:    'ssh-rsa',
                data:    'AAAAAAAAAAAA',
                comment: 'name',
              },
            ],
          }
        end

        it do
          is_expected.to contain_file('/opt/keys')
            .with_content(%r{^ssh-rsa AAAAAAAAAAAA name$})
        end
      end

      context 'when given a key with a command' do
        let(:params) do
          {
            keys: [
              {
                type: 'ssh-rsa',
                data: 'AAAAAAAAAAAA',
                comment: 'name',
                command: '/usr/bin/whatever',
              },
            ],
          }
        end

        it do
          is_expected.to contain_file('/opt/keys')
            .with_content(%r{^command="/usr/bin/whatever" ssh-rsa AAAAAAAAAAAA name$})
        end
      end

      context 'when called /etc/secret/keys and secret is true' do
        let(:title) { '/etc/secret/keys' }
        let(:params) { { secret: true } }

        it do
          is_expected.to contain_file('/etc/secret').with(
            ensure: 'directory',
            mode:   '0700',
          )
        end

        it do
          is_expected.to contain_file('/etc/secret/keys')
            .that_requires('File[/etc/secret]')
        end
      end
    end
  end
end
