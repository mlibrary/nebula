# frozen_string_literal: true

# Copyright (c) 2019-2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::kubernetes::kubectl' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/first_cluster_config.yaml' }
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it { is_expected.to contain_package('kubectl').that_requires('Apt::Source[kubernetes]') }

      it { is_expected.to contain_concat('/var/local/generate_pki.sh') }

      it do
        is_expected.to contain_concat_fragment('cluster pki preamble')
          .with_target('/var/local/generate_pki.sh')
          .with_order('01')
          .with_content(%r{^KUBE_INTERNAL_IP='172\.16\.0\.1'$})
      end

      it do
        is_expected.to contain_concat_fragment('cluster pki functions')
          .with_target('/var/local/generate_pki.sh')
          .with_order('03')
      end

      context 'with cluster set to second_cluster' do
        let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/second_cluster_config.yaml' }

        it do
          is_expected.to contain_concat_fragment('cluster pki preamble')
            .with_content(%r{^KUBE_INTERNAL_IP='192\.168\.0\.1'$})
        end
      end
    end
  end
end
