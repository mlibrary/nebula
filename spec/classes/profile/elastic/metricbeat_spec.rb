# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::elastic::metricbeat' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it do
        is_expected.to contain_service('metricbeat').with(
          ensure: 'running',
          enable: true,
        )
      end

      it { is_expected.to contain_package('metricbeat') }

      it { is_expected.to contain_apt__source('elastic.co') }

      it do
        is_expected.to contain_file('/etc/metricbeat/metricbeat.yml').with(
          ensure: 'present',
          require: 'Package[metricbeat]',
          notify: 'Service[metricbeat]',
          mode: '0644',
        )
      end

      [
        %r{^\s*- module: system$.*^\s*  period: 90s$}m,
        %r{^\s*  hosts: \[['"]logstash\.default\.invalid:1234['"]\]$},
        %r{^\s*#ssl.certificate_authorities:},
      ].each do |content|
        it { is_expected.to contain_file('/etc/metricbeat/metricbeat.yml').with_content(content) }
      end

      context 'given logstash_auth_cert => "/some/file.crt"' do
        let(:params) { { logstash_auth_cert: '/some/file.crt' } }

        it do
          is_expected.to contain_file('/etc/metricbeat/metricbeat.yml').with_content(
            %r{^\s*  ssl\.certificate_authorities: \["/etc/ssl/certs/logstash-forwarder\.crt"\]$},
          )
        end
      end
    end
  end
end
