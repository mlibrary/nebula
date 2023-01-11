# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'
require_relative '../../support/contexts/with_mocked_nodes'

describe 'nebula::profile::http_fileserver' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      include_context 'with mocked query for nodes in other datacenters'

      let(:facts) { os_facts }
      let(:hiera_config) { 'spec/fixtures/hiera/deb_server_config.yaml' }
      let(:node) { "foo.example.com" } # see spec/default_facts.yml

      let(:params) do
        { storage_path: 'somehost:/whatever' }
      end

      it { is_expected.to contain_mount('/srv/www').with(fstype: 'nfs', device: 'somehost:/whatever') }
      it { is_expected.to contain_file('/srv/www').with_ensure('directory') }
      it { is_expected.to contain_file('/var/local/http').with_ensure('directory') }

      it do
        is_expected.to contain_class('apache').with(
          docroot: '/srv/www',
          default_ssl_cert: '/etc/letsencrypt/live/foo.example.com/fullchain.pem',
          default_ssl_key: '/etc/letsencrypt/live/foo.example.com/privkey.pem',
          default_vhost: false,
          default_ssl_vhost: true,
        )
      end

      it do
        is_expected.to contain_apache__vhost("foo.example.com http")
          .with_servername("foo.example.com")
          .with_port(80)
          .with_docroot("/var/local/http")
          .that_requires("File[/var/local/http]")
      end

      it do
        is_expected.to contain_nebula__cert("foo.example.com")
          .with_webroot("/var/local/http")
          .that_requires("File[/var/local/http]")
          .that_requires("Apache::Vhost[foo.example.com http]")
      end

      context "with no existing certificate" do
        let(:node) { "nocert.example.com" }

        it do
          is_expected.to contain_class('apache')
            .with_docroot('/srv/www')
            .with_default_vhost(false)
            .with_default_ssl_vhost(false)
        end

        it do
          is_expected.to contain_apache__vhost("nocert.example.com http")
            .with_servername("nocert.example.com")
            .with_port(80)
            .with_docroot("/var/local/http")
            .that_requires("File[/var/local/http]")
        end

        it do
          is_expected.to contain_nebula__cert("nocert.example.com")
            .with_webroot("/var/local/http")
            .that_requires("File[/var/local/http]")
            .that_requires("Apache::Vhost[nocert.example.com http]")
        end
      end
    end
  end
end
