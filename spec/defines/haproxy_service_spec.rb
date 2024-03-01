# frozen_string_literal: true

# Copyright (c) 2018, 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::haproxy::service' do
  let(:title) { 'svc1' }
  let(:params) { {} }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:params) do
        super().merge(floating_ip: '1.2.3.4')
      end

      let(:facts) do
        os_facts.merge(
          datacenter: 'dc1',
          networking: {
            ip: '40.41.42.43',
          },
        )
      end

      let :pre_condition do
        <<~EOT
          nebula::haproxy::binding { 'scotch svc1':
            service    => 'svc1',
            datacenter => 'dc1',
            hostname   => 'scotch',
            ipaddress  => '111.111.111.123'
          }

          nebula::haproxy::binding { 'soda svc1':
            service    => 'svc1',
            datacenter => 'dc1',
            hostname   => 'soda',
            ipaddress  => '222.222.222.234'
          }
        EOT
      end

      describe 'https service config' do
        let(:service) { title }
        let(:service_config) { '/etc/haproxy/services.d/svc1-https.cfg' }

        it do
          is_expected.to contain_concat(service_config).with(
            ensure: 'present',
            notify: 'Service[haproxy]',
            mode: '0644',
          )
        end

        it do
          is_expected.to contain_concat_fragment('svc1-dc1-https backend').with(
            target: service_config,
            content: "backend svc1-dc1-https-back\n",
          )
        end

        it { is_expected.to contain_concat_fragment('svc1-dc1-https check').with_target(service_config) }

        it do
          is_expected.to contain_concat_fragment('svc1-dc1-https frontend').with(
            target: service_config,
            content: <<~EOT
              frontend svc1-dc1-https-front
              bind 1.2.3.4:443 ssl crt /etc/ssl/private/svc1
              stats uri /haproxy?stats
              http-response set-header "Strict-Transport-Security" "max-age=31536000"
              http-request set-header X-Client-IP %ci
              http-request set-header X-Forwarded-Proto https
              default_backend svc1-dc1-https-back
            EOT
          )
        end

        describe 'with frontend maxconn' do
          let(:params) do
            super().merge(max_frontend_sessions: 999)
          end

          it do
            is_expected.to contain_concat_fragment('svc1-dc1-https frontend').with(
              target: service_config,
              content: %r{^maxconn 999$},
            )
          end
        end

        it do
          is_expected.not_to contain_file('/etc/haproxy/errors/svc1503.http')
        end

        describe 'with custom 503' do
          let(:params) do
            super().merge(custom_503: true)
          end

          it do
            is_expected.to contain_file('/etc/haproxy/errors/svc1503.http')
              .with_source('https://default.http_files.invalid/errorfiles/svc1503.http')
          end

          it do
            is_expected.to contain_concat_fragment('svc1-dc1-https custom 503').with(
              target: service_config,
              content: <<~EOT
                errorfile 503 /etc/haproxy/errors/svc1503.http
              EOT
            )
          end
        end

        describe 'with no block_paths' do
          it 'contains no reference to block_path acl' do
            is_expected.to contain_concat_fragment('svc1-dc1-https frontend').without_content(/block_path/)
          end
        end

        describe 'with block_paths' do
          let(:params) do
            super().merge(block_paths: ['/some/path','/another/path'])
          end

          it 'contains block_path acl' do
            is_expected.to contain_concat_fragment('svc1-dc1-https frontend')
              .with_content(%r|acl block_path path_beg -i /some/path
acl block_path path_beg -i /another/path
http-request deny if block_path|)
          end
        end

        describe 'with throttling parameters' do
          let(:params) do
            super().merge(max_requests_per_sec: 2,
                          max_requests_burst: 400,
                          floating_ip: '1.2.3.4',
                          cert_source: '')
          end

          it do
            is_expected.to contain_concat_fragment('svc1-dc1-https throttling').with(
              target: service_config,
              content: <<~EOT
                stick-table type ip size 200k expire 200s store http_req_rate(200s),bytes_out_rate(200s)
                tcp-request content track-sc2 src
                http-request set-var(req.http_rate) src_http_req_rate(svc1-dc1-http-back)
                http-request set-var(req.https_rate) src_http_req_rate(svc1-dc1-https-back)
                acl http_req_rate_abuse var(req.http_rate),add(req.https_rate) gt 400
                errorfile 403 /etc/haproxy/errors/svc1429.http
                http-request deny deny_status 403 if http_req_rate_abuse
              EOT
            )
          end

          it do
            is_expected.to contain_file('/etc/haproxy/errors/svc1429.http')
              .with_source('https://default.http_files.invalid/errorfiles/svc1429.http')
          end

          context 'with no whitelists' do
            it { is_expected.not_to contain_file('/etc/haproxy/svc1_whitelist_src.txt') }
            it { is_expected.not_to contain_file('/etc/haproxy/svc1_whitelist_path_beg.txt') }
            it { is_expected.not_to contain_file('/etc/haproxy/svc1_whitelist_path_end.txt') }

            it 'does not reference any whitelists' do
              is_expected.to contain_concat_fragment('svc1-dc1-https frontend').with_content(%r{(?!whitelist)})
            end
            it 'does not reference the exemption backend' do
              is_expected.to contain_concat_fragment('svc1-dc1-https frontend').with_content(%r{(?!svc1-dc1-https?-back-exempt)})
            end
          end

          context 'with IP exemptions' do
            let(:params) do
              super().merge(whitelists: { 'src' => ['10.0.0.1', '10.2.32.0/24'] })
            end

            it { is_expected.to contain_file('/etc/haproxy/svc1_whitelist_src.txt').with_content("10.0.0.1\n10.2.32.0/24\n") }

            it do
              is_expected.to contain_concat_fragment('svc1-dc1-https frontend').with_content(%r{#{<<~EOT}}m)
                acl whitelist_src src -n -f /etc/haproxy/svc1_whitelist_src.txt
                use_backend svc1-dc1-https-back-exempt if whitelist_src
                default_backend svc1-dc1-https-back
              EOT
            end

            it do
              is_expected.to contain_concat_fragment('svc1-dc1-https back-exempt')
                .with_content("backend svc1-dc1-https-back-exempt\n")
            end

            it do
              is_expected.to contain_concat_fragment('svc1-dc1-https scotch binding')
                .with_content("server scotch 111.111.111.123:443 check cookie s123\n")
            end
            it do
              is_expected.to contain_concat_fragment('svc1-dc1-https soda binding')
                .with_content("server soda 222.222.222.234:443 check cookie s234\n")
            end
          end

          context 'with path & suffix exemptions' do
            let(:params) do
              super().merge(whitelists: { 'path_beg' => ['/some/where', '/another/path'],
                                          'path_end' => ['.abc', '.def'] })
            end

            ['acl whitelist_path_beg path_beg -n -f /etc/haproxy/svc1_whitelist_path_beg.txt',
             'acl whitelist_path_end path_end -n -f /etc/haproxy/svc1_whitelist_path_end.txt',
             'use_backend svc1-dc1-https-back-exempt if whitelist_path_beg OR whitelist_path_end']
              .each do |fragment|
              it do
                is_expected.to contain_concat_fragment('svc1-dc1-https frontend')
                  .with_content(%r{#{fragment}})
              end
            end

            it do
              is_expected.to contain_file('/etc/haproxy/svc1_whitelist_path_beg.txt').with_content(<<~EOT)
                /some/where
                /another/path
              EOT
            end

            it do
              is_expected.to contain_file('/etc/haproxy/svc1_whitelist_path_end.txt').with_content(<<~EOT)
                .abc
                .def
              EOT
            end
          end

          context 'with throttling condition' do
            let(:params) do
              super().merge(throttle_condition: 'path_beg /whatever')
            end

            ['acl throttle_condition path_beg /whatever',
             'use_backend svc1-dc1-https-back-exempt if !throttle_condition'].each do |fragment|
              it do
                is_expected.to contain_concat_fragment('svc1-dc1-https frontend')
                  .with_content(%r{#{fragment}})
              end
            end

            it do
              is_expected.to contain_concat_fragment('svc1-dc1-https scotch exempt binding')
                .with_content("server scotch 111.111.111.123:443 track svc1-dc1-https-back/scotch cookie s123\n")
            end
            it do
              is_expected.to contain_concat_fragment('svc1-dc1-https soda exempt binding')
                .with_content("server soda 222.222.222.234:443 track svc1-dc1-https-back/soda cookie s234\n")
            end
          end
        end

        context 'with dynamic weighting' do
          let(:params) do
            super().merge(dynamic_weighting: true)
          end

          it do
            is_expected.to contain_cron('dynamic weighting for svc1')
              .with_command('/usr/bin/ruby /usr/local/bin/set_weights.rb dc1 svc1 > /dev/null 2>&1')
              .with_user('haproxyctl')
              .with_environment(['HAPROXY_SMOOTHING_FACTOR=2'])
          end
        end

        it { is_expected.not_to contain_concat_fragment('svc1-dc1-https check_timeout') }

        context 'with check_timeout_milliseconds set to 15000' do
          let(:params) do
            super().merge(check_timeout_milliseconds: 15000)
          end

          it do
            is_expected.to contain_concat_fragment('svc1-dc1-https check_timeout')
              .with_target(service_config)
              .with_content("timeout connect 15000\n")
          end
        end
      end

      describe 'http service config' do
        let(:service) { title }
        let(:service_config) { '/etc/haproxy/services.d/svc1-http.cfg' }

        it { is_expected.to contain_concat(service_config).with(ensure: 'present') }
        it { is_expected.to contain_concat(service_config).with(notify: 'Service[haproxy]') }
        it { is_expected.to contain_concat(service_config).with(mode: '0644') }

        it do
          is_expected.to contain_concat_fragment('svc1-dc1-http frontend').with(
            target: service_config,
            content: <<~EOT
              frontend svc1-dc1-http-front
              bind 1.2.3.4:80
              stats uri /haproxy?stats
              http-request set-header X-Client-IP %ci
              http-request set-header X-Forwarded-Proto http
              default_backend svc1-dc1-http-back
            EOT
          )
        end

        it do
          is_expected.to contain_concat_fragment('svc1-dc1-http backend').with(
            target: service_config,
            content: "backend svc1-dc1-http-back\n",
          )
        end

        it do
          is_expected.to contain_concat_fragment('svc1-dc1-http scotch binding')
            .with_content("server scotch 111.111.111.123:80 track svc1-dc1-https-back/scotch cookie s123\n")
        end
        it do
          is_expected.to contain_concat_fragment('svc1-dc1-http soda binding')
            .with_content("server soda 222.222.222.234:80 track svc1-dc1-https-back/soda cookie s234\n")
        end
      end

      describe 'ssl certs' do
        let(:dest) { '/etc/ssl/private/svc1' }

        context 'with an empty source' do
          it { is_expected.not_to contain_file(dest) }
        end

        context 'with a source' do
          let(:params) do
            {
              floating_ip: '1.2.3.4',
              cert_source: '/some/where',
            }
          end

          it do
            is_expected.to contain_file(dest).with(
              ensure: 'directory',
              notify: 'Service[haproxy]',
              require: 'Package[haproxy]',
              mode: '0700',
              owner: 'haproxy',
              group: 'haproxy',
              recurse: true,
              source: "puppet://#{params[:cert_source]}/svc1",
              path: dest,
              links: 'follow',
              purge: true,
            )
          end
        end
      end
    end
  end
end
