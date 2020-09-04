# frozen_string_literal: true

# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::prometheus::exporter::haproxy' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts.merge(datacenter: 'mydatacenter') }
      let(:params) { { master: false } }

      it { is_expected.to compile }
      it { is_expected.to contain_package('prometheus-haproxy-exporter') }

      it do
        is_expected.to contain_service('prometheus-haproxy-exporter')
          .with_ensure('running')
          .with_enable(true)
      end

      it 'defines a systemd service' do
        is_expected.to contain_file('/etc/systemd/system/prometheus-haproxy-exporter.service')
          .that_requires('Package[prometheus-haproxy-exporter]')
          .that_notifies('Service[prometheus-haproxy-exporter]')
      end

      it 'defines default file' do
        is_expected.to contain_file('/etc/default/prometheus-haproxy-exporter')
          .that_requires('Package[prometheus-haproxy-exporter]')
          .that_notifies('Service[prometheus-haproxy-exporter]')
      end

      it 'exports target data' do
        expect(exported_resources).to contain_concat_fragment("prometheus haproxy service #{facts[:hostname]}")
          .with_target('/etc/prometheus/haproxy.yml')
          .with_tag('mydatacenter_prometheus_haproxy_service_list')
      end

      context 'with master set to false' do
        let(:params) { { master: false } }

        it 'exports target data with priority backup' do
          expect(exported_resources).to contain_concat_fragment("prometheus haproxy service #{facts[:hostname]}")
            .with_content(%r{priority: 'backup'})
        end
      end

      context 'with master set to true' do
        let(:params) { { master: true } }

        it 'exports target data with priority primary' do
          expect(exported_resources).to contain_concat_fragment("prometheus haproxy service #{facts[:hostname]}")
            .with_content(%r{priority: 'primary'})
        end
      end

      context 'with master unset' do
        let(:params) { {} }

        it { is_expected.not_to compile }
      end

      context 'at datacenter fakedatacenter' do
        let(:facts) { os_facts.merge(datacenter: 'fakedatacenter') }

        it do
          expect(exported_resources).to contain_concat_fragment("prometheus haproxy service #{facts[:hostname]}")
            .with_tag('fakedatacenter_prometheus_haproxy_service_list')
        end
      end
    end
  end
end
