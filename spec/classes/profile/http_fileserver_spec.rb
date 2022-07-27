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
      let(:fqdn) { facts[:fqdn] }

      let(:params) do
        { storage_path: 'somehost:/whatever' }
      end

      it do
        is_expected.to contain_class('apache').with(
          docroot: '/srv/www',
          default_ssl_chain: '/etc/ssl/certs/incommon_sha2.crt',
          default_ssl_cert: "/etc/ssl/certs/#{fqdn}.crt",
          default_ssl_key: "/etc/ssl/private/#{fqdn}.key",
        )
      end

      it { is_expected.to contain_mount('/srv/www').with(fstype: 'nfs', device: 'somehost:/whatever') }
      it { is_expected.to contain_file("/etc/ssl/certs/#{fqdn}.crt") }
      it { is_expected.to contain_file("/etc/ssl/private/#{fqdn}.key") }
      it { is_expected.to contain_file('/etc/ssl/certs/intermediate_ca.crt') }

      context "with chain_crt set to abc.crt" do
        let(:params) do
          super().merge(chain_crt: 'abc.crt')
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('apache').with_default_ssl_chain('/etc/ssl/certs/abc.crt') }
      end
    end
  end
end
