# frozen_string_literal: true

# Copyright (c) 2020, 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

[
  ['api',        6443, 'check check-ssl verify none'],
  ['etcd',       2379, 'check'],
  ['http',      30080, 'check send-proxy'],
  ['https',     30443, 'check send-proxy'],
  ['https_alt', 31443, 'check'],
  ['gelf_tcp',  32201, 'check'],
].each do |service, port, options|
  describe "nebula::profile::kubernetes::destination_port::#{service}" do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/first_cluster_config.yaml' }
        let(:facts) { os_facts }

        it { is_expected.to compile }

        describe 'exported resources' do
          subject { exported_resources }

          it do
            is_expected.to contain_concat_fragment("haproxy kubernetes #{service.tr('_', ' ')} #{facts[:hostname]}")
              .with_target("/etc/haproxy/services.d/#{service}.cfg")
              .with_order('02')
              .with_content("  server #{facts[:hostname]} #{facts[:ipaddress]}:#{port} #{options}\n")
              .with_tag("first_cluster_haproxy_kubernetes_#{service}")
          end
        end
      end
    end
  end
end
