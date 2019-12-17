# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::kubernetes::worker' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:hiera_config) { 'spec/fixtures/hiera/kubernetes_config.yaml' }
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_class('Nebula::Profile::Kubernetes') }
      it { is_expected.to contain_package('nfs-common') }

      describe 'exported resources' do
        subject { exported_resources }

        it do
          is_expected.to contain_concat_fragment("haproxy nodeports #{facts[:hostname]}")
            .with_target('/etc/haproxy/haproxy.cfg')
            .with_order('04')
            .with_content("  server #{facts[:hostname]} #{facts[:ipaddress]} check port 30000\n")
            .with_tag('first_cluster_haproxy_nodeports')
        end

        it do
          is_expected.to contain_concat_fragment("haproxy ip #{os_facts[:hostname]}")
            .with_target('/etc/kubernetes_addresses.yaml')
            .with_content("addresses: {work: {#{os_facts[:hostname]}: '#{os_facts[:ipaddress]}'}}")
            .with_tag('first_cluster_proxy_ips')
        end
      end
    end
  end
end
