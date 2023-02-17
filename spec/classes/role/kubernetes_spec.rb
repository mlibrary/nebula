# frozen_string_literal: true

# Copyright (c) 2019-2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

%w[primary backup].each do |tier|
  describe "nebula::role::kubernetes::#{tier}_gateway" do
    on_supported_os.each do |os, os_facts|
      next if os == 'debian-8-x86_64'

      context "on #{os}" do
        let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/first_cluster_config.yaml' }
        let(:facts) do
          os_facts.merge(
            'networking'   => {
              'interfaces' => {
                'ens4'     => {
                  'ip'     => '10.123.234.5',
                },
              },
            },
          )
        end

        it { is_expected.to contain_class('Nebula::Profile::Ntp') }

        it { is_expected.to contain_service('haproxy').that_notifies('Service[keepalived]') }
      end
    end
  end
end

%w[controller etcd worker].each do |role|
  describe "nebula::role::kubernetes::#{role}" do
    on_supported_os.each do |os, os_facts|
      next if os == 'debian-8-x86_64'

      context "on #{os}" do
        let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/first_cluster_config.yaml' }
        let(:facts) do
          os_facts.merge(
            'networking'   => {
              'interfaces' => {
                'ens4'     => {
                  'ip'     => '10.123.234.5',
                },
              },
            },
          )
        end

        it { is_expected.to contain_class('Nebula::Profile::Chrony') }

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

        case role
        when 'etcd'
          it do
            expect(exported_resources).to contain_concat_fragment("cluster pki for #{facts[:hostname]}")
              .with_tag('first_cluster_pki_generation')
              .with_target('/var/local/generate_pki.sh')
              .with_order('02')
              .with_content("ETCD_NODES=(\"${ETCD_NODES[@]}\" \"#{facts[:hostname]}/#{facts[:ipaddress]}\")\n")
          end
        when 'controller'
          it do
            expect(exported_resources).to contain_concat_fragment("cluster pki for #{facts[:hostname]}")
              .with_tag('first_cluster_pki_generation')
              .with_target('/var/local/generate_pki.sh')
              .with_order('02')
              .with_content("KUBE_CONTROLLERS=(\"${KUBE_CONTROLLERS[@]}\" \"#{facts[:hostname]}/#{facts[:ipaddress]}\")\n")
          end
        when 'worker'
          it do
            expect(exported_resources).to contain_concat_fragment("cluster pki for #{facts[:hostname]}")
              .with_tag('first_cluster_pki_generation')
              .with_target('/var/local/generate_pki.sh')
              .with_order('02')
              .with_content("KUBE_WORKERS=(\"${KUBE_WORKERS[@]}\" \"#{facts[:hostname]}/#{facts[:ipaddress]}\")\n")
          end

          it { is_expected.to contain_package('lvm2') }
        end
      end
    end
  end
end
