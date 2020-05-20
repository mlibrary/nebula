# frozen_string_literal: true

# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::kubernetes::prometheus' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/first_cluster_config.yaml' }
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it { is_expected.to contain_file('/var/local/prometheus').with_ensure('directory') }

      it do
        is_expected.to contain_concat_file('/etc/prometheus/nodes.yml')
          .with_path('/var/local/prometheus/nodes.yml')
          .with_require('File[/var/local/prometheus]')
      end
    end
  end
end
