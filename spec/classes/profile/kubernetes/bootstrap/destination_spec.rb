# frozen_string_literal: true

# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::kubernetes::bootstrap::destination' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/first_cluster_config.yaml' }
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it do
        is_expected.to contain_file('/var/lib/kubeadm_bootstrap/.ssh/authorized_keys')
          .with_owner('kubeadm_bootstrap')
          .with_content("first cluster public key value\n")
          .that_requires('File[/var/lib/kubeadm_bootstrap/.ssh]')
      end

      context 'with cluster set to second_cluster' do
        let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/second_cluster_config.yaml' }

        it do
          is_expected.to contain_file('/var/lib/kubeadm_bootstrap/.ssh/authorized_keys')
            .with_content("general public key value\n")
        end
      end
    end
  end
end
