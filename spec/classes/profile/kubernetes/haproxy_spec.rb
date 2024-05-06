# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::kubernetes::haproxy' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/first_cluster_config.yaml' }
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it { is_expected.to contain_package('haproxy') }
      it { is_expected.to contain_package('haproxyctl') }

      it do
        is_expected.to contain_service('haproxy')
          .with_ensure('running')
          .with_enable(true)
          .that_requires('Package[haproxy]')
      end

      it do
        is_expected.to contain_nebula__authzd_user('haproxyctl')
          .with_gid('haproxy')
          .with_home('/var/haproxyctl')
      end

      describe '/etc/default/haproxy' do
        let(:file) { '/etc/default/haproxy' }

        it do
          is_expected.to contain_file(file)
            .with_content(%r{^CONFIG="/etc/haproxy/haproxy\.cfg"$})
            .with_content(%r{^EXTRAOPTS="-f /etc/haproxy/services\.d"$})
            .that_notifies('Service[haproxy]')
        end
      end

      describe '/etc/haproxy/haproxy.cfg' do
        let(:file) { '/etc/haproxy/haproxy.cfg' }

        it { is_expected.to contain_file(file).that_notifies('Service[haproxy]') }
      end

      describe '/etc/haproxy/services.d' do
        let(:services) { '/etc/haproxy/services.d' }

        it { is_expected.to contain_file('/etc/haproxy/services.d').with_ensure('directory') }

        [
          [:kube_api, 6443,  'api'],
          [:etcd,     2379,  'etcd'],
          [:public,   80,    'http'],
          [:public,   443,   'https'],
          [:private,  8443,  'https_alt'],
          [:private,  12201, 'gelf_tcp'],
        ].each do |ip, port, service|
          describe 'the firewall' do
            case ip
            when :public
              it do
                is_expected.to contain_firewall("200 public #{service}")
                  .with_proto('tcp')
                  .with_state('NEW')
                  .with_jump('accept')
                  .with_dport(port)
                  .without_source
              end
            when :private
              it do
                is_expected.to contain_nebula__exposed_port("200 private #{service}")
                  .with_port(port)
                  .with_block('umich::networks::datacenter')
              end
            else
              it do
                is_expected.to contain_firewall("200 private #{service}")
                  .with_proto('tcp')
                  .with_state('NEW')
                  .with_jump('accept')
                  .with_dport(port)
                  .with_source('172.28.0.0/14')
              end
            end
          end

          describe "/etc/haproxy/services.d/#{service}.cfg" do
            let(:file) { "/etc/haproxy/services.d/#{service}.cfg" }
            let(:fragment) { "haproxy kubernetes #{service}" }
            let(:ip_address) do
              {
                public: '10.0.0.1',
                private: '10.0.0.1',
                kube_api: '172.16.0.7',
                etcd: '172.16.0.6',
              }[ip]
            end

            it { is_expected.to contain_concat(file).that_notifies('Service[haproxy]') }
            it { is_expected.to contain_concat_fragment(fragment).with_target(file) }
            it { is_expected.to contain_concat_fragment(fragment).with_order('01') }

            [
              %r{^frontend kubernetes-#{service.tr('_', '-')}-front$},
              %r{^backend kubernetes-#{service.tr('_', '-')}-back$},
              %r{^  default_backend kubernetes-#{service.tr('_', '-')}-back$},
            ].each do |line|
              it { is_expected.to contain_concat_fragment(fragment).with_content(line) }
            end

            it do
              is_expected.to contain_concat_fragment(fragment)
                .with_content(%r{^  bind #{ip_address}:#{port}$})
            end

            context 'with cluster set to second_cluster' do
              let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/second_cluster_config.yaml' }
              let(:ip_address) do
                {
                  public: '10.0.0.2',
                  private: '10.0.0.2',
                  kube_api: '172.16.1.7',
                  etcd: '172.16.1.6',
                }[ip]
              end

              it do
                is_expected.to contain_concat_fragment(fragment)
                  .with_content(%r{^  bind #{ip_address}:#{port}$})
              end
            end
          end
        end
      end
    end
  end
end
