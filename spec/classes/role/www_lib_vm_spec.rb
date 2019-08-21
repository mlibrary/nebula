# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

require_relative '../../support/contexts/with_mocked_nodes'

describe 'nebula::role::webhost::www_lib_vm' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts.merge(hostname: 'thisnode', datacenter: 'somedc') }
      let(:rolenode) { { 'ip' => Faker::Internet.ip_v4_address, 'hostname' => 'rolenode' } }
      let(:hiera_config) { 'spec/fixtures/hiera/www_lib_config.yaml' }

      include_context 'with mocked puppetdb functions', 'somedc', %w[rolenode], 'nebula::profile::haproxy' => %w[]

      it { is_expected.to compile }

      it { is_expected.to contain_class('php') }

      it { is_expected.to contain_mount('/www') }

      it { is_expected.to contain_apache__vhost('000-default').with(port: 80, ssl: false) }

      it { is_expected.to contain_apache__vhost('000-default-ssl').with(ssl: true, ssl_cert: '/etc/ssl/certs/www.lib.umich.edu.crt') }

      it do
        is_expected.to contain_apache__vhost('www.lib-ssl')
          .with(servername: 'www.lib.umich.edu',
                port: 443,
                ssl: true,
                ssl_cert: '/etc/ssl/certs/www.lib.umich.edu.crt')
      end

      it do
        is_expected.to contain_concat_fragment('www.lib-ssl-ssl')
          .with_content(%r{^\s*SSLCertificateFile\s*"/etc/ssl/certs/www.lib.umich.edu.crt"$})
      end

      it do
        is_expected.to contain_concat_file('/usr/local/lib/cgi-bin/monitor/monitor_config.yaml')
      end

      it do
        is_expected.to contain_concat_fragment('www.lib-ssl-cosign')
          .with_content(%r{^\s*CosignCrypto\s*/etc/ssl/private/www.lib.umich.edu.key /etc/ssl/certs/www.lib.umich.edu.crt /etc/ssl/certs})
      end

      # from hiera
      it { is_expected.to contain_host('mysql-web').with_ip('10.0.0.123') }

      it do
        # set via hiera
        is_expected.to contain_file('authz_umichlib.conf')
          .with_content(%r{DBDParams\s*user=somebody})
      end

      it do
        is_expected.to contain_apache__vhost('000-default-ssl')
          .with_aliases([{ 'scriptalias' => '/monitor',
                           'path' => '/usr/local/lib/cgi-bin/monitor' }])
      end

      it do
        is_expected.to contain_apache__vhost('datamart-https')
          .with_servername('datamart.lib.umich.edu')
      end

      it do
        is_expected.to contain_apache__vhost('theater-historiography.org-https')
          .with_ssl_cert('/etc/ssl/certs/www.theater-historiography.org.crt')
          .with_redirect_dest('https://www.theater-historiography.org/')
          .with_serveraliases(%w[www.theater-historiography.com
                                 theater-historiography.com
                                 www.theatre-historiography.com
                                 theatre-historiography.com
                                 www.theatre-historiography.org
                                 theatre-historiography.org])
      end
    end
  end
end
