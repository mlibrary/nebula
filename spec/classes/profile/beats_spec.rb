# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::beats' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it do
        is_expected.to contain_service('metricbeat').with(
          ensure: 'running',
          enable: true,
          require: 'File[/etc/metricbeat/metricbeat.yml]',
        )
      end

      it do
        is_expected.to contain_service('filebeat').with(
          ensure: 'running',
          enable: true,
          # require: 'File[/etc/filebeat/filebeat.yml]',
        )
      end

      it do
        is_expected.to contain_package('metricbeat')
          .without_ensure
          .that_requires('Apt::Source[elastic.co]')
      end

      it do
        is_expected.to contain_package('filebeat')
          .without_ensure
          .that_requires('Apt::Source[elastic.co]')
      end

      it do
        is_expected.to contain_apt__source('elastic.co').with(
          comment: 'Elastic.co apt source for beats and elastic search',
          require: 'Package[apt-transport-https]',
          location: 'https://artifacts.elastic.co/packages/5.x/apt',
          release: 'stable',
          repos: 'main',
          key: {
            'id'     => '46095ACC8548582C1A2699A9D27D666CD88E42B4',
            'server' => 'keyserver.ubuntu.com',
          },
          include: {
            'src' => false,
            'deb' => true,
          },
        )
      end

      it { is_expected.to contain_package('apt-transport-https').without_ensure }

      it do
        is_expected.to contain_file('/etc/metricbeat/metricbeat.yml').with(
          ensure: 'present',
          require: 'Package[metricbeat]',
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

      it do
        is_expected.to contain_file('/etc/filebeat/filebeat.yml').with(
          ensure: 'present',
          require: 'Package[filebeat]',
          mode: '0644',
        )
      end

      [
        %r{^\s*config_dir: prospectors$},
        %r{^\s*hosts:.*"logstash.umdl.umich.edu:5044"},
      ].each do |content|
        it { is_expected.to contain_file('/etc/filebeat/filebeat.yml').with_content(content) }
      end

      it do
        is_expected.to contain_file('/etc/filebeat/prospectors').with(
          ensure: 'directory',
          require: 'Package[filebeat]',
        )
      end

      it { is_expected.not_to contain_file('/etc/ssl/certs') }
      it { is_expected.not_to contain_file('/etc/ssl/certs/logstash-forwarder.crt') }

      context 'given logstash_auth_cert => "/some/file.crt"' do
        let(:params) { { logstash_auth_cert: '/some/file.crt' } }

        it do
          is_expected.to contain_file('/etc/ssl/certs/logstash-forwarder.crt').with(
            ensure: 'present',
            require: 'File[/etc/ssl/certs]',
            mode: '0644',
            source: 'puppet:///some/file.crt',
          )
        end

        it do
          is_expected.to contain_file('/etc/ssl/certs').with(
            ensure: 'directory',
            mode: '0755',
          )
        end

        it do
          is_expected.to contain_file('/etc/metricbeat/metricbeat.yml').with_content(
            %r{^\s*  ssl\.certificate_authorities: \["/etc/ssl/certs/logstash-forwarder\.crt"\]$},
          )
        end
      end

      context 'given logstash_auth_cert => "/another/cert.crt"' do
        let(:params) { { logstash_auth_cert: '/another/cert.crt' } }

        it do
          is_expected.to contain_file('/etc/ssl/certs/logstash-forwarder.crt').with(
            source: 'puppet:///another/cert.crt',
          )
        end
      end
    end
  end
end
