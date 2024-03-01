# frozen_string_literal: true

# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::kubernetes::etcdctl' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/first_cluster_config.yaml' }
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_package("etcd-client") }
      it { is_expected.to contain_file("/etc/etcd").with_ensure("directory") }
      it { is_expected.to contain_file("/etc/etcd/README") }

      it do
        is_expected.to contain_file("/etc/profile.d/etcdctl.sh")
          .with_content(/ETCDCTL_ENDPOINTS="10.1.2.3:2379,10.2.4.6:2379,10.3.6.9:2379"/)
      end

      context "in the second cluster" do
        let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/second_cluster_config.yaml' }

        it do
          is_expected.to contain_file("/etc/profile.d/etcdctl.sh")
            .with_content(/ETCDCTL_ENDPOINTS="192.168.2.3:2379,192.168.4.6:2379,192.168.6.9:2379"/)
        end
      end
    end
  end
end
