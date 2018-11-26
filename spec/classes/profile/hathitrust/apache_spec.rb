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
      end
    end
  end
end
