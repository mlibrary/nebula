# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::prometheus::exporter::node' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it do
        is_expected.to contain_file('/etc/default/prometheus-node-exporter')
          .that_notifies('Service[prometheus-node-exporter]')
          .that_requires('Package[prometheus-node-exporter]')
      end

      it { is_expected.to contain_service('prometheus-node-exporter') }
      it { is_expected.to contain_package('prometheus-node-exporter') }

      it "exports itself to the default datacenter's service discovery" do
        expect(exported_resources).to contain_concat_fragment("prometheus node service #{facts[:hostname]}")
          .with_tag('default_prometheus_node_service_list')
          .with_target('/etc/prometheus/nodes.yml')
          .with_content(%r{'#{facts[:ipaddress]}:9100'})
      end

      context 'when our datacenter is covered' do
        let(:params) { { covered_datacenters: %w[mydatacenter] } }

        it "exports itself to its datacenter's service discovery" do
          expect(exported_resources).to contain_concat_fragment("prometheus node service #{facts[:hostname]}")
            .with_tag('mydatacenter_prometheus_node_service_list')
        end
      end
    end
  end
end
