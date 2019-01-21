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

      it do
        is_expected.to contain_file('/etc/systemd/system/unison-client@myinstance.service.d/drop-in.conf')
          .with_content(%r{.*Requires=fs1.mount.*ExecStart.*/usr/local/bin/unisonsync myinstance.*}m)
      end

      it do
        is_expected.to contain_file('/root/.unison/myinstance.prf')
          .with_content(<<~EOT)
            root = /myroot
            root = socket://somehost.default.invalid:12345/myroot

            path = path1
            path = path2

            batch		      = true
            confirmbigdel	= true
            prefer		    = newer
            group		      = true
            logfile		    = /var/log/unison_myinstance.log
            owner		      = true
            times		      = true
            numericids	  = true
        EOT
      end

      it do
        is_expected.to contain_service('unison-client@myinstance')
          .with(enable: true, ensure: 'running')
          .that_requires('Package[unison]')
      end

      xit 'log rotation'

      it 'exports firewall resource' do
        expect(exported_resources).to contain_firewall("200 Unison: myinstance #{facts[:hostname]}").with(
          proto: 'tcp',
          dport: [12_345],
          source: facts[:ipaddress],
          tag: 'unison-client-myinstance',
        )
      end
    end
  end
end
