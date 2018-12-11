# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::elastic' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it do
        is_expected.to contain_apt__source('elastic.co').with(
          comment: 'Elastic.co apt source for beats and elastic search',
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
