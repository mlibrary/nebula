# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::kubernetes' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:hiera_config) { 'spec/fixtures/hiera/kubernetes_config.yaml' }
      let(:facts) { os_facts }

      context 'with cluster unset' do
        let(:params) { { cluster: nil } }

        it { is_expected.not_to compile }
      end

      context 'with cluster set to one without a docker version' do
        let(:params) { { cluster: 'implicit_docker_version' } }

        it { is_expected.not_to compile }
      end

      context 'with cluster set to one without a kubernetes version' do
        let(:params) { { cluster: 'implicit_kubernetes_version' } }

        it { is_expected.not_to compile }
      end

      context 'with cluster set to first_cluster' do
        let(:params) { { cluster: 'first_cluster' } }

        %w[kubeadm kubelet].each do |package|
          it { is_expected.to contain_package(package).with_ensure('1.14.2-00') }

          [
            'Class[Docker]',
            'Apt::Source[kubernetes]',
          ].each do |requirement|
            it { is_expected.to contain_package(package).that_requires(requirement) }
          end
        end

        it do
          is_expected.to contain_apt__pin('kubernetes').with(
            packages: %w[kubeadm kubelet],
            version: '1.14.2-00',
          )
        end

        it do
          is_expected.to contain_file('/etc/systemd/system/docker.service.d')
            .with_ensure('directory')
        end

        it do
          is_expected.to contain_class('nebula::profile::docker').with(
            version: '5:18.09.6~3-0~debian-stretch',
          )
        end

        it do
          is_expected.to contain_apt__source('kubernetes').with(
            location: 'https://apt.kubernetes.io/',
            release: 'kubernetes-xenial',
            repos: 'main',
            key: {
              'id'     => '54A647F9048D5688D7DA2ABE6A030B21BA07F4FB',
              'source' => 'https://packages.cloud.google.com/apt/doc/apt-key.gpg',
            },
          )
        end

        describe 'exported resources' do
          subject { exported_resources }

          [
            ['API', 6443],
            ['NodePort', '30000-32767'],
            ['BGP', 179],
          ].each do |purpose, port|
            it do
              is_expected.to contain_firewall("200 first_cluster #{purpose} #{facts[:fqdn]}").with(
                proto: 'tcp',
                dport: port,
                source: facts[:ipaddress],
                state: 'NEW',
                action: 'accept',
                tag: "first_cluster_#{purpose}",
              )
            end
          end

          it do
            is_expected.to contain_firewall("200 first_cluster VXLAN #{facts[:fqdn]}").with(
              proto: 'udp',
              dport: 4789,
              source: facts[:ipaddress],
              state: 'NEW',
              action: 'accept',
              tag: 'first_cluster_VXLAN',
            )
          end
        end
      end

      context 'with cluster set to second_cluster' do
        let(:params) { { cluster: 'second_cluster' } }

        it { is_expected.to contain_package('kubeadm').with_ensure('1.11.9-00') }
        it { is_expected.to contain_package('kubelet').with_ensure('1.11.9-00') }
        it { is_expected.to contain_class('nebula::profile::docker').with_version('18.06.2~ce~3-0~debian') }
        it { is_expected.to contain_apt__pin('kubernetes').with_version('1.11.9-00') }

        describe 'exported resources' do
          subject { exported_resources }

          it { is_expected.to contain_firewall("200 second_cluster API #{facts[:fqdn]}") }
          it { is_expected.to contain_firewall("200 second_cluster NodePort #{facts[:fqdn]}") }
        end
      end
    end
  end
end
