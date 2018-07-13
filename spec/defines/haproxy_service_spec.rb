# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'
require_relative '../support/contexts/with_mocked_nodes'

describe 'nebula::haproxy_service' do
  let(:title) { 'svc1' }
  let(:params) { {} }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:scotch) { { 'ip' => '111.111.111.123', 'hostname' => 'scotch' } }
      let(:soda)   { { 'ip' => '222.222.222.234', 'hostname' => 'soda' } }
      let(:third_server) { { 'ip' => '222.222.222.235', 'hostname' => 'third_server' } }
      let(:params) do
        { floating_ip: '1.2.3.4',
          node_names: %w[scotch soda],
          cert_source: '' }
      end

      let(:facts) do
        os_facts.merge(
          datacenter: 'hatcher',
          networking: {
            ip: '40.41.42.43',
          },
        )
      end

      include_context 'with mocked puppetdb functions', 'hatcher', %w[scotch soda third_server]

      describe 'service config file' do
        let(:service) { title }
        let(:file) { '/etc/haproxy/svc1.cfg' }

        it { is_expected.to contain_file(file).with(ensure: 'present') }
        it { is_expected.to contain_file(file).with(require: 'Package[haproxy]') }
        it { is_expected.to contain_file(file).with(notify: 'Service[haproxy]') }
        it { is_expected.to contain_file(file).with(mode: '0644') }

        it 'says it is managed by puppet' do
          is_expected.to contain_file(file).with_content(
            %r{\A# Managed by puppet \(nebula\/profile\/haproxy\/service\.cfg\.erb\)\n},
          )
        end

        [
          "frontend svc1-hatcher-http-front\n" \
          "  bind 1.2.3.4:80,40.41.42.43:80\n" \
          "  stats uri \/haproxy?stats\n" \
          "  default_backend svc1-hatcher-http-back\n" \
          "  http-request set-header X-Client-IP %ci\n" \
          "  http-request set-header X-Forwarded-Proto http\n",
          "frontend svc1-hatcher-https-front\n" \
          "  bind 1.2.3.4:443,40.41.42.43:443 ssl crt /etc/ssl/private/svc1\n" \
          "  stats uri /haproxy?stats\n" \
          "  default_backend svc1-hatcher-https-back\n" \
          "  http-response set-header \"Strict-Transport-Security\" \"max-age=31536000\"\n" \
          "  http-request set-header X-Client-IP %ci\n" \
          "  http-request set-header X-Forwarded-Proto https\n",
        ].each do |stanza|
          it 'contains the stanza' do
            is_expected.to contain_file(file)
            actual = catalogue.resource('file', file).send(:parameters)[:content]
            expect(actual).to include(stanza)
          end
        end

        [
          "backend svc1-hatcher-http-back\n" \
          "  http-check expect status 200\n" \
          "  server scotch 111.111.111.123:80 check cookie s123\n" \
          "  server soda 222.222.222.234:80 check cookie s234\n",

          "backend svc1-hatcher-https-back\n" \
          "  http-check expect status 200\n" \
          "  server scotch 111.111.111.123:443 check cookie s123\n" \
          "  server soda 222.222.222.234:443 check cookie s234\n",
        ].each do |stanza|
          it "contains the stanza #{stanza.split("\n").first}" do
            is_expected.to contain_file(file).with_content(%r{#{stanza}}m)
          end
        end
      end

      describe 'ssl certs' do
        let(:dest) { '/etc/ssl/private/svc1' }

        context 'with an empty source' do
          it { is_expected.not_to contain_file(dest) }
        end

        context 'with a source' do
          let(:params) do
            { floating_ip: '1.2.3.4',
              cert_source: '/some/where' }
          end

          it { is_expected.to contain_file(dest).with(ensure: 'directory') }
          it { is_expected.to contain_file(dest).with(notify: 'Service[haproxy]') }
          it { is_expected.to contain_file(dest).with(mode: '0700') }
          it { is_expected.to contain_file(dest).with(owner: 'haproxy') }
          it { is_expected.to contain_file(dest).with(group: 'haproxy') }
          it { is_expected.to contain_file(dest).with(recurse: true) }
          it { is_expected.to contain_file(dest).with(source: "puppet://#{params[:cert_source]}/svc1") }
          it { is_expected.to contain_file(dest).with(path: dest) }
          it { is_expected.to contain_file(dest).with(links: 'follow') }
          it { is_expected.to contain_file(dest).with(purge: true) }
        end
      end
    end
  end
end
