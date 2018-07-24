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
      let(:base_params) do
        { floating_ip: '1.2.3.4',
          node_names: %w[scotch soda],
          cert_source: '' }
      end
      let(:params) { base_params }

      let(:facts) do
        os_facts.merge(
          datacenter: 'hatcher',
          networking: {
            ip: '40.41.42.43',
          },
        )
      end

      include_context 'with mocked puppetdb functions', 'hatcher', %w[scotch soda third_server], {}

      describe 'service config file' do
        let(:service) { title }
        let(:service_config) { '/etc/haproxy/services.d/svc1.cfg' }

        it { is_expected.to contain_file(service_config).with(ensure: 'present') }
        it { is_expected.to contain_file(service_config).with(notify: 'Service[haproxy]') }
        it { is_expected.to contain_file(service_config).with(mode: '0644') }

        it 'says it is managed by puppet' do
          is_expected.to contain_file(service_config).with_content(
            %r{\A# Managed by puppet \(nebula\/profile\/haproxy\/service\.cfg\.erb\)\n},
          )
        end

        [
          "frontend svc1-hatcher-http-front\n" \
          "  bind 1.2.3.4:80\n" \
          "  stats uri \/haproxy?stats\n" \
          "  default_backend svc1-hatcher-http-back\n" \
          "  http-request set-header X-Client-IP %ci\n" \
          "  http-request set-header X-Forwarded-Proto http\n",
          "frontend svc1-hatcher-https-front\n" \
          "  bind 1.2.3.4:443 ssl crt /etc/ssl/private/svc1\n" \
          "  stats uri /haproxy?stats\n" \
          "  default_backend svc1-hatcher-https-back\n" \
          "  http-response set-header \"Strict-Transport-Security\" \"max-age=31536000\"\n" \
          "  http-request set-header X-Client-IP %ci\n" \
          "  http-request set-header X-Forwarded-Proto https\n",
        ].each do |stanza|
          it 'contains the stanza' do
            is_expected.to contain_file(service_config)
            actual = catalogue.resource('file', service_config).send(:parameters)[:content]
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
            is_expected.to contain_file(service_config).with_content(%r{#{stanza}}m)
          end
        end
        describe 'with throttling parameters' do
          let(:throttling_params) do
            base_params.merge(max_requests_per_sec: 2,
                              max_requests_burst: 400,
                              floating_ip: '1.2.3.4',
                              node_names: %w[scotch soda],
                              cert_source: '')
          end
          let(:params) { throttling_params }

          ["  stick-table type ip size 200k expire 200s store gpc0\n" \
               "  acl source_is_abuser src_get_gpc0\\(svc1-hatcher-http-front\\) gt 0\n" \
               "  use_backend svc1-blocked if source_is_abuser\n" \
               '  tcp-request connection track-sc0 src',

           "  stick-table type ip size 200k expire 200s store http_req_rate\\(200s\\),bytes_out_rate\\(200s\\)\n" \
           "  tcp-request content track-sc2 src\n" \
           "  acl http_req_rate_abuse src_http_req_rate\\(svc1-hatcher-http-back\\) gt 10\n" \
           "  acl mark_as_abuser src_inc_gpc0\\(svc1-hatcher-http-front\\) gt 0\n" \
           "  http-request deny deny_status 503 if http_req_rate_abuse mark_as_abuser\n",

           "backend svc1-blocked\n"\
           "  http-request deny deny_status 503\n"].each do |stanza|

            it 'contains the throttling config stanza' do
              is_expected.to contain_file(service_config).with_content(%r{#{stanza}}m)
            end
          end

          context 'with no whitelists' do
            it { is_expected.not_to contain_file('/etc/haproxy/svc1_whitelist_src.txt') }
            it { is_expected.not_to contain_file('/etc/haproxy/svc1_whitelist_path_beg.txt') }
            it { is_expected.not_to contain_file('/etc/haproxy/svc1_whitelist_path_end.txt') }
            it 'does not reference any whitelists' do
              is_expected.to contain_file(service_config).with_content(%r{(?!whitelist)})
            end
          end

          context 'with IP exemptions' do
            let(:params) { throttling_params.merge(whitelists: { 'src' => ['10.0.0.1', '10.2.32.0/24'] }) }

            it { is_expected.to contain_file(service_config).with_content(%r{acl whitelist_src src -n -f /etc/haproxy/svc1_whitelist_src.txt}) }
            it { is_expected.to contain_file(service_config).with_content(%r{deny_status 503 if !whitelist_src http_req_rate_abuse}) }
            it { is_expected.to contain_file('/etc/haproxy/svc1_whitelist_src.txt').with_content("10.0.0.1\n10.2.32.0/24\n") }
          end

          context 'with path & suffix exemptions' do
            let(:params) do
              throttling_params.merge(whitelists: { 'path_beg' => ['/some/where', '/another/path'],
                                                    'path_end' => ['.abc', '.def'] })
            end

            it { is_expected.to contain_file(service_config).with_content(%r{acl whitelist_path_beg path_beg -n -f /etc/haproxy/svc1_whitelist_path_beg.txt}) }
            it { is_expected.to contain_file(service_config).with_content(%r{acl whitelist_path_end path_end -n -f /etc/haproxy/svc1_whitelist_path_end.txt}) }

            it { is_expected.to contain_file(service_config).with_content(%r{deny_status 503 if !whitelist_path_beg !whitelist_path_end http_req_rate_abuse}) }

            it { is_expected.to contain_file('/etc/haproxy/svc1_whitelist_path_beg.txt').with_content("/some/where\n/another/path\n") }
            it { is_expected.to contain_file('/etc/haproxy/svc1_whitelist_path_end.txt').with_content(".abc\n.def\n") }
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
