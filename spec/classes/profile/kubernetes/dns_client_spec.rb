# frozen_string_literal: true

# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::kubernetes::dns_client' do
  on_supported_os.each do |os, os_facts|
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

      it { is_expected.to compile }

      it do
        expect(exported_resources).to contain_concat_fragment("/etc/hosts ipv4 #{facts[:ipaddress]}")
          .with_target('/etc/hosts')
          .with_order('04')
          .with_content("#{facts[:ipaddress]} #{facts[:fqdn]} #{facts[:hostname]}\n")
      end

      it do
        is_expected.to contain_file('/etc/resolv.conf')
          .with_content("search first.cluster\nnameserver 172.16.0.1\n")
      end
    end
  end
end
