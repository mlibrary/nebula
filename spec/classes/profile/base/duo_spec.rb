# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::base::duo' do
  def contain_pam_duo
    contain_file('/etc/security/pam_duo.conf')
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to contain_package('sudo') }
      it { is_expected.to contain_package('libpam-duo') }

      it do
        is_expected.to contain_file_line('/etc/pam.d/sshd: pam_duo')
          .with_path('/etc/pam.d/sshd')
          .with_line('auth required pam_duo.so')
          .with_after('^@include common-auth')
          .that_requires(['Package[sudo]', 'Package[libpam-duo]'])
      end

      it do
        is_expected.to contain_file_line('/etc/pam.d/sudo: pam_duo')
          .with_path('/etc/pam.d/sudo')
          .with_line('auth required pam_duo.so')
          .with_after('^@include common-auth')
          .that_requires(['Package[sudo]', 'Package[libpam-duo]'])
      end

      it do
        is_expected.to contain_pam_duo
          .with_mode('0600')
          .that_requires('Package[libpam-duo]')
      end

      [
        %r{^ikey = ikey\.default\.invalid$},
        %r{^skey = skey\.default\.invalid$},
        %r{^host = host\.default\.invalid$},
        %r{^pushinfo = push\.default\.invalid$},
        %r{^failmode = fail\.default\.invalid$},
      ].each do |line|
        it { is_expected.to contain_pam_duo.with_content(line) }
      end

      [
        [:ikey, 'REALIKEY'],
        [:skey, 'REALSKEY'],
        [:host, 'REALHOST'],
        [:pushinfo, 'REALPUSH'],
        [:failmode, 'REALFAIL'],
      ].each do |key, value|
        context "given a #{key} of #{value}" do
          let(:params) { { key => value } }

          it { is_expected.to contain_pam_duo.with_content(%r{^#{key} = #{value}$}) }
        end
      end
    end
  end
end
