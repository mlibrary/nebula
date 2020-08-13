# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::unison::client' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'myinstance' }
      let(:params) do
        {
          server: 'somehost.default.invalid',
          port: 12_345,
          root: '/myroot',
          paths: %w[path1 path2],
          filesystems: ['fs1'],
        }
      end

      [
        'Description=myinstance somehost.default.invalid sync \(unison\)',
        'Requires=fs1.mount',
        'WatchdogSec=7200',
        'Environment=HOME=/root',
        'ExecStart=/usr/local/bin/unisonsync myinstance',
      ].each do |line|
        it do
          is_expected.to contain_file('/etc/systemd/system/unison-client-myinstance.service')
            .with_content(%r{^#{line}$}m)
        end
      end

      it 'generates a prf file for unison clients' do
        is_expected.to contain_file('/root/.unison/myinstance.prf')
          .with_content(%r{root\s+=\s+/myroot})
          .with_content(%r{root\s+=\s+socket://somehost.default.invalid:12345/myroot})
          .with_content(%r{path\s+=\s+path1})
          .with_content(%r{path\s+=\s+path2})
          .with_content(%r{batch\s+=\s+true})
          .with_content(%r{confirmbigdel\s+=\s+true})
          .with_content(%r{prefer\s+=\s+newer})
          .with_content(%r{group\s+=\s+true})
          .with_content(%r{logfile\s+=\s+/var/log/unison_myinstance.log})
          .with_content(%r{owner\s+=\s+true})
          .with_content(%r{times\s+=\s+true})
          .with_content(%r{numericids\s+=\s+true})
          .without_content(%r{ignore\s+=\s+Path})
      end

      it do
        is_expected.to contain_service('unison-client-myinstance')
          .with(enable: true, ensure: 'running')
          .that_requires('Package[unison]')
      end

      it 'exports firewall resource' do
        expect(exported_resources).to contain_firewall("200 Unison: myinstance #{facts[:hostname]}").with(
          proto: 'tcp',
          dport: [12_345],
          source: facts[:ipaddress],
          tag: 'unison-client-myinstance',
        )
      end

      context 'with optional params' do
        let(:params) do
          {
            server: 'somehost.default.invalid',
            port: 12_345,
            root: '/myroot',
            paths: %w[path1 path2],
            filesystems: ['fs1'],
            ignores: %w[ignore_path1 ignore_path2],
          }
        end

        it 'generates a prf file for unison clients' do
          is_expected.to contain_file('/root/.unison/myinstance.prf')
            .with_content(%r{root\s+=\s+/myroot})
            .with_content(%r{root\s+=\s+socket://somehost.default.invalid:12345/myroot})
            .with_content(%r{path\s+=\s+path1})
            .with_content(%r{path\s+=\s+path2})
            .with_content(%r{batch\s+=\s+true})
            .with_content(%r{confirmbigdel\s+=\s+true})
            .with_content(%r{prefer\s+=\s+newer})
            .with_content(%r{group\s+=\s+true})
            .with_content(%r{logfile\s+=\s+/var/log/unison_myinstance.log})
            .with_content(%r{owner\s+=\s+true})
            .with_content(%r{times\s+=\s+true})
            .with_content(%r{numericids\s+=\s+true})
            .with_content(%r{ignore\s+=\s+Path\s+ignore_path1})
            .with_content(%r{ignore\s+=\s+Path\s+ignore_path2})
        end
      end
    end
  end
end
