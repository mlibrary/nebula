# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

%w[controller worker].each do |role|
  describe "nebula::role::legacy::kubernetes::#{role}" do
    on_supported_os.each do |os, os_facts|
      next if os == 'debian-8-x86_64'

      context "on #{os}" do
        let(:hiera_config) { 'spec/fixtures/hiera/kubernetes_config.yaml' }
        let(:facts) { os_facts }

        it { is_expected.not_to contain_resources('firewall').with_purge(true) }

        it do
          is_expected.to contain_firewallchain('INPUT:filter:IPv4').with(
            ensure: 'present',
            purge: true,
            ignore: ['-j cali-INPUT',
                     '-j KUBE-FIREWALL',
                     '-j KUBE-SERVICES',
                     '-j KUBE-EXTERNAL-SERVICES'],
          )
        end

        it do
          is_expected.to contain_firewallchain('OUTPUT:filter:IPv4').with(
            ensure: 'present',
            purge: true,
            ignore: ['-j cali-OUTPUT',
                     '-j KUBE-FIREWALL',
                     '-j KUBE-SERVICES'],
          )
        end

        it do
          is_expected.to contain_firewallchain('FORWARD:filter:IPv4').with(
            ensure: 'present',
            purge: true,
            ignore: ['-j cali-FORWARD',
                     '-j KUBE-FORWARD',
                     '-j KUBE-SERVICES'],
          )
        end
      end
    end
  end
end
