# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::networking::sshd' do
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

      context 'with no keytab' do
        it do
          is_expected.not_to contain_sshd.with_content(
            %r{^GSSAPIAuthentication yes$}m,
          )
        end
      end

      context 'with a keytab' do
        let(:pre_condition) do
          <<~EOT
            class { 'nebula::profile::networking::keytab':
              keytab => 'nebula/keytab.fake',
              keytab_source => 'alternate source'
            }
          EOT
        end

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

      it { is_expected.to contain_file('/etc/pam.d/sshd-defaults') }

      it { is_expected.to contain_concat_file('/etc/pam.d/sshd').with_path('/etc/pam.d/sshd') }

      it do
        is_expected.to contain_concat_fragment('/etc/pam.d/sshd: base')
          .with_target('/etc/pam.d/sshd')
          .with_content(%r{@include sshd-defaults})
      end
    end
  end
end
