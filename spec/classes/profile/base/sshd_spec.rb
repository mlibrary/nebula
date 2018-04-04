# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::base::sshd' do
  def contain_sshd
    contain_file('/etc/ssh/sshd_config')
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to contain_sshd.that_notifies('Service[sshd]') }

      it do
        is_expected.to contain_service('sshd').only_with(
          ensure: 'running',
          enable: true,
          hasrestart: true,
        )
      end

      [
        %r{^PermitRootLogin (prohibit|without)-password$},
        %r{^PubkeyAuthentication no$},
        %r{^PasswordAuthentication no$},
        %r{^ChallengeResponseAuthentication yes$},
        %r{^GSSAPIAuthentication no$},
        %r{^GSSAPICleanupCredentials yes$},
        %r{^UsePAM yes$},
        %r{^X11Forwarding yes$},
        %r{^PrintMotd no$},
        %r{^UsePrivilegeSeparation yes$},
        %r{^AcceptEnv LANG LC_\*$},
        %r{^Subsystem\s+sftp\s+/usr/lib/openssh/sftp-server$},
        %r{^Match Address 10\.1\.1\.0/24,10\.2\.2\.0/24,!10\.2\.2\.2\n\s*PubkeyAuthentication yes$}m,
      ].each do |line|
        it { is_expected.to contain_sshd.with_content(line) }
      end

      it "doesn't contain whitelist settings other than pubkey" do
        is_expected.to contain_sshd.without_content(
          %r{^Match Address [0-9.,/!]+\n\s*PubkeyAuthentication yes\n.}m,
        )
      end

      context 'when given no whitelist' do
        let(:params) { { whitelist: [] } }

        it do
          is_expected.to contain_sshd.without_content(
            %r{^Match Address},
          )
        end
      end

      context 'when gssapi_auth is true' do
        let(:params) { { gssapi_auth: true } }

        it do
          is_expected.to contain_sshd.with_content(
            %r{^Match Address [0-9.,/!]+\n\s*PubkeyAuthentication yes\n\s*GSSAPIAuthentication yes$}m,
          )
        end
      end

      it do
        is_expected.to contain_file('/etc/ssh/ssh_config')
          .with_content(%r{^\s*SendEnv LANG LC_\*$})
      end
    end
  end
end
