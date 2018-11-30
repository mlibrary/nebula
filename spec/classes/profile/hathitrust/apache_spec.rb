# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'
require_relative '../../../support/contexts/with_mocked_nodes'

describe 'nebula::profile::hathitrust::apache' do
  def multiline2re(string)
    Regexp.new(string.split("\n").map { |line| Regexp.escape(line.lstrip) }.join('\n\s*'))
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:vhost_config) { 'babel.hathitrust.org ssl-directories' }
      let(:hiera_config) { 'spec/fixtures/hiera/hathitrust_config.yaml' }
      let(:haproxy) { { 'ip' => Faker::Internet.ip_v4_address, 'hostname' => 'haproxy' } }
      let(:rolenode) { { 'ip' => Faker::Internet.ip_v4_address, 'hostname' => 'rolenode' } }

      include_context 'with mocked puppetdb functions', 'somedc', %w[haproxy rolenode], 'nebula::profile::haproxy' => %w[haproxy]

      snippets = [
        <<~EOT,
          <Directory "/htapps/babel/imgsrv/cgi">
            AllowOverride None

            <Files "imgsrv">
              SetHandler proxy:fcgi://127.0.0.1:31028
            </Files>
          </Directory>
        EOT
        <<~EOT
          <DirectoryMatch "^/htapps/babel/([^/]+)/cgi">
            Options +ExecCGI
            SetHandler cgi-script
          </DirectoryMatch>
        EOT
      ]

      snippets.each do |snippet|
        it { is_expected.to contain_concat_fragment(vhost_config).with_content(multiline2re(snippet)) }
      end

      it do
        is_expected.to contain_file('access_compat.load')
          .with(path: '/etc/apache2/mods-available/access_compat.load',
                content: %r{LoadModule access_compat_module /usr/lib/apache2/modules/mod_access_compat.so})
      end

      it do
        is_expected.to contain_file('access_compat.load symlink')
          .with(ensure: 'link',
                path: '/etc/apache2/mods-enabled/access_compat.load',
                target: '/etc/apache2/mods-available/access_compat.load')
      end

      describe 'Production HT hostnames' do
        %w[babel catalog www].each do |vhost|
          it {
            is_expected.to contain_apache__vhost("#{vhost}.hathitrust.org ssl").with(
              servername: "#{vhost}.hathitrust.org",
              ssl: true,
              ssl_cert: '/etc/ssl/certs/www.hathitrust.org.crt',
              ssl_key: '/etc/ssl/private/www.hathitrust.org.key',
              ssl_chain: '/etc/ssl/certs/incommon_sha2.crt',
            )
          }
        end
      end

      context 'with a domain and prefix specified' do
        let(:params) do
          {
            domain: 'example.org',
            prefix: 'foo.',
          }
        end

        it { is_expected.to contain_apache__vhost('foo.babel.example.org ssl').with_servername('foo.babel.example.org') }
        it { is_expected.to contain_apache__vhost('foo.catalog.example.org ssl').with_servername('foo.catalog.example.org') }
        it { is_expected.to contain_apache__vhost('foo.www.example.org ssl').with_servername('foo.www.example.org') }

        it {
          is_expected.to contain_apache__vhost('foo.babel.example.org non-ssl').with(
            redirect_dest: 'https://foo.babel.example.org',
            servername: 'foo.babel.example.org',
          )
        }
      end

      context 'with a domain and no prefix specified' do
        let(:params) do
          {
            domain: 'example.org',
          }
        end

        it { is_expected.to contain_apache__vhost('babel.example.org ssl').with_servername('babel.example.org') }

        it {
          is_expected.to contain_apache__vhost('hathitrust canonical name redirection').with(
            servername: 'example.org',
            serveraliases: ['domain.one', 'domain.two', 'www.domain.one', 'www.domain.two'],
            redirect_dest: 'https://www.example.org',
          )
        }
      end
    end
  end
end
