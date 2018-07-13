# frozen_string_literal: true

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
      let(:fqdn) { facts[:fqdn] }

      it { is_expected.to contain_service('puppet').without_ensure }
      it { is_expected.to contain_service('puppet').with_enable(true) }

      case os
      when 'debian-8-x86_64'
        it { is_expected.not_to contain_class('nebula::profile::afs') }
        it { is_expected.not_to contain_base_class('authorized_keys') }
        it { is_expected.not_to contain_base_class('exim4') }
        it { is_expected.not_to contain_base_class('firewall::ipv4') }
        it { is_expected.not_to contain_base_class('grub') }
        it { is_expected.not_to contain_base_class('ntp') }
        it { is_expected.not_to contain_base_class('sysctl') }
        it { is_expected.not_to contain_base_class('sshd') }
        it { is_expected.not_to contain_base_class('users') }
        it { is_expected.not_to contain_base_class('vim') }
      when 'debian-9-x86_64'
        it { is_expected.to contain_class('nebula::profile::afs') }
        it { is_expected.to contain_base_class('authorized_keys') }
        it { is_expected.to contain_base_class('exim4') }
        it { is_expected.to contain_base_class('firewall::ipv4') }
        it { is_expected.to contain_base_class('grub') }
        it { is_expected.to contain_base_class('ntp') }
        it { is_expected.to contain_base_class('users') }
        it { is_expected.to contain_base_class('vim') }


        it { is_expected.to contain_package('dselect') }
        it { is_expected.to contain_package('ifenslave') }
        it { is_expected.to contain_package('linux-image-amd64') }
        it { is_expected.to contain_package('vlan') }
        it { is_expected.to contain_package('tiger') }
        it { is_expected.to contain_package('dbus') }
        it { is_expected.to contain_package('dkms') }

        it do
          is_expected.to contain_file('/etc/localtime')
            .with_ensure('link')
            .with_target('/usr/share/zoneinfo/US/Eastern')
        end

        it do
          is_expected.to contain_file('/etc/timezone')
            .with_content("US/Eastern\n")
        end

        context 'with timezone set to America/Detroit' do
          let(:params) { { timezone: 'America/Detroit' } }

          it do
            is_expected.to contain_file('/etc/localtime')
              .with_ensure('link')
              .with_target('/usr/share/zoneinfo/America/Detroit')
          end

          it do
            is_expected.to contain_file('/etc/timezone')
              .with_content("America/Detroit\n")
          end
        end

        it do
          is_expected.to contain_file('/etc/hostname')
            .with_content("#{fqdn}\n")
            .that_notifies("Exec[/bin/hostname #{fqdn}]")
        end

        it do
          is_expected.to contain_exec("/bin/hostname #{fqdn}")
            .with_refreshonly(true)
        end

        it { is_expected.to contain_base_class('sysctl').with_bridge(false) }

        context 'with bridge_network set to true' do
          let(:params) { { bridge_network: true } }

          it { is_expected.to contain_base_class('sysctl').with_bridge(true) }
        end

        it { is_expected.to contain_base_class('sshd').with_gssapi_auth(false) }
        it { is_expected.not_to contain_file('/etc/krb5.keytab') }

        context 'when given an existing keytab file' do
          let(:params) { { keytab: 'nebula/keytab.fake' } }

          it { is_expected.to contain_base_class('sshd').with_gssapi_auth(true) }

          it do
            is_expected.to contain_file('/etc/krb5.keytab').with(
              mode: '0600',
              content: %r{^This is not a real keytab.},
            )
          end
        end

        context 'when given a nonexistent keytab file' do
          let(:params) { { keytab: 'nebula/keytab.not_a_file' } }

          it { is_expected.to contain_base_class('sshd').with_gssapi_auth(false) }
          it { is_expected.not_to contain_file('/etc/krb5.keytab') }
        end

        context 'when given a keytab source and no keytab' do
          let(:params) { { keytab_source: 'alternate source' } }

          it { is_expected.not_to contain_file('/etc/krb5.keytab') }
        end

        context 'when given a keytab source and a nonexistent keytab' do
          let :params do
            {
              keytab: 'nebula/keytab.not_a_file',
              keytab_source: 'alternate source',
            }
          end

          it { is_expected.not_to contain_file('/etc/krb5.keytab') }
        end

        context 'when given a keytab source and a real keytab' do
          let :params do
            {
              keytab: 'nebula/keytab.fake',
              keytab_source: 'alternate source',
            }
          end

          it do
            is_expected.to contain_file('/etc/krb5.keytab').with(
              mode: '0600',
              source: 'alternate source',
            )
          end
        end

        it do
          is_expected.to contain_file('/etc/motd')
            .with_content(%r{contact us at contact@default\.invalid\.$})
            .with_content(%r{administered by Default Incorrect Dept\.$})
        end

        context 'when given a contact_email of the_dean@umich.edu' do
          let(:params) { { contact_email: 'the_dean@umich.edu' } }

          it do
            is_expected.to contain_file('/etc/motd')
              .with_content(%r{contact us at the_dean@umich\.edu\.$})
          end
        end

        context 'when given a sysadmin_dept of The Cool Team' do
          let(:params) { { sysadmin_dept: 'The Cool Team' } }

          it do
            is_expected.to contain_file('/etc/motd')
              .with_content(%r{administered by The Cool Team\.$})
          end
        end

        # This is an ugly hack for fixing AEIM-1064. See base.pp for
        # more details about when it might be safe to remove this.
        %w[procps sshd].each do |service|
          it do
            is_expected.to contain_exec("/bin/systemctl status #{service}")
              .that_subscribes_to(['Service[procps]', 'Service[sshd]'])
              .with_refreshonly(true)
          end
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
