# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::unison::server' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'myinstance' }
      let(:params) do
        {
          root: '/myroot',
          paths: %w[path1 path2],
          filesystems: ['fs1'],
          port: 12_345,
        }
      end

      it { is_expected.to contain_package('unison') }

      [
        'Description=myinstance Unison',
        'Requires=fs1.mount',
        'Environment=HOME=/root',
        'ExecStart=/usr/bin/unison -socket 12345',
      ].each do |line|
        it do
          is_expected.to contain_file('/etc/systemd/system/unison-myinstance.service')
            .with_content(%r{^#{line}$}m)
        end
      end

      it do
        is_expected.to contain_service('unison-myinstance')
          .with(enable: true, ensure: 'running')
          .that_requires('Package[unison]')
      end

      it 'exports client' do
        expect(exported_resources).to contain_nebula__unison__client('myinstance').with(
          server: facts[:fqdn],
          # from hiera
          port: 12_345,
          root: '/myroot',
          paths: %w[path1 path2],
          filesystems: ['fs1'],
        )
      end
    end
  end
end
