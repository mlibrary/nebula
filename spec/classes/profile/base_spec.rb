# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::base' do
  def contain_base_class(name)
    contain_class("nebula::profile::base::#{name}")
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      case os
      when 'debian-8-x86_64'
        it { is_expected.not_to contain_base_class('authorized_keys') }
        it { is_expected.not_to contain_base_class('firewall::ipv4') }
        it { is_expected.not_to contain_base_class('sysctl') }
        it { is_expected.not_to contain_base_class('sshd') }
      when 'debian-9-x86_64'
        [
          %r{^APT::Install-Recommends "0";$},
          %r{^APT::Install-Suggests "0";$},
        ].each do |line|
          it do
            is_expected.to contain_file('/etc/apt/apt.conf.d/99no-recommends')
              .with_content(line)
          end
        end

        it { is_expected.to contain_base_class('authorized_keys') }
        it { is_expected.to contain_base_class('firewall::ipv4') }

        it { is_expected.to contain_base_class('sysctl').with_bridge(false) }

        context 'with bridge_network set to true' do
          let(:params) { { bridge_network: true } }

          it { is_expected.to contain_base_class('sysctl').with_bridge(true) }
        end

        it { is_expected.to contain_base_class('sshd').with_gssapi_auth(false) }
        it { is_expected.not_to contain_file('/etc/krb5.keytab') }

        context 'when given a keytab file that has to exist' do
          let(:params) { { keytab: 'hiera.yaml' } }

          it { is_expected.to contain_base_class('sshd').with_gssapi_auth(true) }

          it do
            is_expected.to contain_file('/etc/krb5.keytab').with(
              source: 'file://hiera.yaml',
              mode: '0600',
            )
          end
        end

        context 'when given a keytab file that does not exist' do
          let(:params) { { keytab: file_that_does_not_exist } }

          it { is_expected.to contain_base_class('sshd').with_gssapi_auth(false) }
          it { is_expected.not_to contain_file('/etc/krb5.keytab') }
        end
      end

      it do
        is_expected.to contain_service('mcollective').with(
          ensure: 'stopped',
          enable: false,
        )
      end

      context 'on an HP machine' do
        let(:facts) do
          super().merge('dmi' => { 'manufacturer' => 'HP' })
        end

        it do
          is_expected.to contain_kmod__blacklist('hpwdt').with(
            file: '/etc/modprobe.d/kpwdt-blacklist.conf',
          )
        end
      end

      context 'on an Dell machine' do
        let(:facts) do
          super().merge('dmi' => { 'manufacturer' => 'Dell Inc.' })
        end

        it { is_expected.not_to contain_kmod__blacklist('hpwdt') }
      end
    end
  end
end

def file_that_does_not_exist
  # Create a random new file and get its path.
  file = Tempfile.new
  path = file.path

  # Close and unlink the file.
  file.close!

  path
end
