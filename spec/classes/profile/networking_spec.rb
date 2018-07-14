# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::networking' do
  def contain_network_class(name)
    contain_class("nebula::profile::networking::#{name}")
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'when keytab==false, bridge==false' do
        let(:params) {{ keytab: false, bridge: false }}
        it { is_expected.to contain_network_class('sysctl').with_bridge(false) }
        it { is_expected.not_to contain_network_class('keytab') }
        it { is_expected.to contain_network_class('sshd').with_gssapi_auth(false) }
      end

      context 'when keytab==true, bridge==false' do
        let(:params) {{ keytab: true, bridge: false }}
        it { is_expected.to contain_network_class('sysctl').with_bridge(false) }
        it { is_expected.to contain_network_class('keytab') }
        it { is_expected.to contain_network_class('sshd').with_gssapi_auth(true) }
      end

      context 'when keytab==false, bridge==true' do
        let(:params) {{ keytab: false, bridge: true }}
        it { is_expected.to contain_network_class('sysctl').with_bridge(true) }
        it { is_expected.not_to contain_network_class('keytab') }
        it { is_expected.to contain_network_class('sshd').with_gssapi_auth(false) }
      end

      context 'when keytab==true, bridge==true' do
        let(:params) {{ keytab: true, bridge: true }}
        it { is_expected.to contain_network_class('sysctl').with_bridge(true) }
        it { is_expected.to contain_network_class('keytab') }
        it { is_expected.to contain_network_class('sshd').with_gssapi_auth(true) }
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
  end
end
