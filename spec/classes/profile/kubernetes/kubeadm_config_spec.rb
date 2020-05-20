# frozen_string_literal: true

# Copyright (c) 2019-2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::kubernetes::kubeadm_config' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with cluster set to first_cluster' do
        let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/first_cluster_config.yaml' }

        it { is_expected.to compile }

        [
          %r{^apiVersion: 'kubeadm\.k8s\.io/v1beta2'$},
          %r{^kind: 'ClusterConfiguration'$},
          %r{^kubernetesVersion: '1\.14\.2'$},
          %r{^controlPlaneEndpoint: 'kube-api\.first\.cluster:6443'$},
          %r{^ +podSubnet: '172\.24\.0\.0/14'$},
          %r{^ +serviceSubnet: '172\.16\.0\.0/13'$},
          %r{^etcd:$},
          %r{^ +external:$},
          %r{^ +endpoints: \['https://172\.16\.0\.6:2379'\]$},
          %r{^ +caFile: '/etc/kubernetes/pki/etcd/ca\.crt'$},
          %r{^ +certFile: '/etc/kubernetes/pki/apiserver-etcd-client\.crt'$},
          %r{^ +keyFile: '/etc/kubernetes/pki/apiserver-etcd-client\.key'$},
        ].each do |line|
          it { is_expected.to contain_file('/etc/kubeadm_config.yaml').with_content(line) }
        end
      end

      context 'with cluster set to second_cluster' do
        let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/second_cluster_config.yaml' }

        [
          %r{^kubernetesVersion: '1\.11\.9'$},
          %r{^controlPlaneEndpoint: 'kube-api\.second\.cluster:6443'$},
          %r{^ +podSubnet: '10\.96\.0\.0/12'$},
          %r{^ +serviceSubnet: '192\.168\.0\.0/16'$},
        ].each do |line|
          it { is_expected.to contain_file('/etc/kubeadm_config.yaml').with_content(line) }
        end
      end
    end
  end
end
