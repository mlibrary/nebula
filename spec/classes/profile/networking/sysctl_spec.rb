# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::networking::sysctl' do
  def contain_sysctl
    contain_file('/etc/sysctl.conf')
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to contain_sysctl.that_notifies('Service[procps]') }

      it do
        is_expected.to contain_service('procps').only_with(
          ensure: 'running',
          enable: true,
          hasrestart: true,
        )
      end

      [
        %r{^net\.ipv4\.conf\.default\.rp_filter\s*=\s*1$},
        %r{^net\.ipv4\.conf\.all\.rp_filter\s*=\s*1$},
        %r{^net\.ipv4\.tcp_syncookies\s*=\s*1$},
        %r{^net\.ipv4\.conf\.all\.accept_redirects\s*=\s*0$},
        %r{^net\.ipv6\.conf\.all\.accept_redirects\s*=\s*0$},
        %r{^net\.ipv4\.conf\.all\.secure_redirects\s*=\s*1$},
        %r{^net\.ipv4\.conf\.all\.send_redirects\s*=\s*0$},
        %r{^net\.ipv4\.conf\.all\.accept_source_route\s*=\s*0$},
        %r{^net\.ipv6\.conf\.all\.accept_source_route\s*=\s*0$},
        %r{^net\.ipv4\.conf\.all\.log_martians\s*=\s*1$},
      ].each do |line|
        it { is_expected.to contain_sysctl.with_content(line) }
      end

      [
        %r{^net\.bridge\.bridge-nf-call-ip6tables\s*=\s*0$},
        %r{^net\.bridge\.bridge-nf-call-iptables\s*=\s*0$},
        %r{^net\.bridge\.bridge-nf-call-arptables\s*=\s*0$},
      ].each do |line|
        it { is_expected.to contain_sysctl.without_content(line) }
      end

      context 'when called with bridge set to true' do
        let(:params) { { bridge: true } }

        [
          %r{^net\.bridge\.bridge-nf-call-ip6tables\s*=\s*0$},
          %r{^net\.bridge\.bridge-nf-call-iptables\s*=\s*0$},
          %r{^net\.bridge\.bridge-nf-call-arptables\s*=\s*0$},
        ].each do |line|
          it { is_expected.to contain_sysctl.with_content(line) }
        end
      end
    end
  end
end
