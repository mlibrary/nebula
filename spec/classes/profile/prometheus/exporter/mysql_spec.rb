# frozen_string_literal: true

# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::prometheus::exporter::mysql' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts.merge(datacenter: 'mydatacenter') }

      it { is_expected.to compile }
      it { is_expected.to contain_package('prometheus-mysqld-exporter') }

      it do
        is_expected.to contain_service('prometheus-mysqld-exporter')
          .with_ensure('running')
          .with_enable(true)
      end

      it 'defines a systemd service' do
        is_expected.to contain_file('/etc/systemd/system/prometheus-mysqld-exporter.service')
          .that_requires('Package[prometheus-mysqld-exporter]')
          .that_notifies('Service[prometheus-mysqld-exporter]')
      end

      it 'defines default file' do
        is_expected.to contain_file('/etc/default/prometheus-mysqld-exporter')
          .that_requires('Package[prometheus-mysqld-exporter]')
          .that_notifies('Service[prometheus-mysqld-exporter]')
      end

      it "exports itself to the default datacenter's service discovery" do
        expect(exported_resources).to contain_concat_fragment("prometheus mysql service #{facts[:hostname]}")
          .with_tag('mydatacenter_prometheus_mysql_service_list')
          .with_target('/etc/prometheus/mysql.yml')
          .with_content(%r{'#{facts[:ipaddress]}:9104'})
      end
    end
  end
end
