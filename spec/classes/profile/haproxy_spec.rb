# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::haproxy' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:default_file) { '/etc/default/haproxy' }
      let(:base_file) { '/etc/haproxy/haproxy.cfg' }
      let(:backend_file) { '/etc/haproxy/backends.cfg' }
      let(:frontend_file) { '/etc/haproxy/frontends.cfg' }
      let(:facts) do
        os_facts.merge(
          datacenter: 'hatcher',
          networking: {
            ip: '40.41.42.43',
          },
        )
      end
      let(:scotch) { { 'ip' => '111.111.111.123', 'hostname' => 'scotch' } }
      let(:soda)   { { 'ip' => '222.222.222.234', 'hostname' => 'soda' } }
      let(:params) { { floating_ip: '1.2.3.4' } }
      let(:pre_condition) do
        'function nodes_for_role($role) {
          if $role == "nebula::role::webhost::www_lib" {
            return ["rolenode", "scotch", "soda"]
          } else {
            return 0
          }
        }

        function nodes_for_datacenter($dc) {
          if $dc == "hatcher" {
            return ["dcnode", "scotch", "anotherdcnode", "soda"]
          } else {
            return 0
          }
        }

        function fact_for($node, $fact) {
          if $fact != "networking" {
            return 0
          }

          case $node {
            "scotch": {
              $result = {
                "ip" => "111.111.111.123",
                "hostname" => "scotch",
              }
            }

            "soda": {
              $result = {
                "ip" => "222.222.222.234",
                "hostname" => "soda",
              }
            }
          }

          return $result
        }'
      end

      describe 'services' do
        it do
          is_expected.to contain_service('haproxy').with(
            ensure: 'running',
            enable: true,
            hasrestart: true,
          )
        end
      end

      describe 'packages' do
        it { is_expected.to contain_package('haproxy') }
        it { is_expected.to contain_package('haproxyctl') }
      end

      describe 'base config file' do
        let(:file) { base_file }

        it { is_expected.to contain_file(file).with(ensure: 'present') }
        it { is_expected.to contain_file(file).with(require: 'Package[haproxy]') }
        it { is_expected.to contain_file(file).with(notify: 'Service[haproxy]') }
        it { is_expected.to contain_file(file).with(mode: '0644') }

        it 'says it is managed by puppet' do
          is_expected.to contain_file(file).with_content(
            %r{\A# Managed by puppet \(nebula\/profile\/haproxy\/haproxy\.cfg\.erb\)\n},
          )
        end
        it 'has a global section' do
          is_expected.to contain_file(file).with_content(%r{^global\n})
        end
        it 'has a defaults section' do
          is_expected.to contain_file(file).with_content(%r{^defaults\n})
        end
        it 'does not have a backend section' do
          is_expected.not_to contain_file(file).with_content(%r{^backend\W+.*\n})
        end
        it 'does not have a frontend section' do
          is_expected.not_to contain_file(file).with_content(%r{^frontend\W+.*\n})
        end
      end

      describe 'default file' do
        let(:file) { default_file }

        it { is_expected.to contain_file(file).with(ensure: 'present') }
        it { is_expected.to contain_file(file).with(require: 'Package[haproxy]') }
        it { is_expected.to contain_file(file).with(notify: 'Service[haproxy]') }
        it { is_expected.to contain_file(file).with(mode: '0644') }

        it 'says it is managed by puppet' do
          is_expected.to contain_file(file).with_content(
            %r{\A# Managed by puppet \(nebula\/profile\/haproxy\/default\.erb\)\n},
          )
        end
        it 'sets $CONFIG to the base config' do
          is_expected.to contain_file(file).with_content(%r{^CONFIG="#{base_file}"\n})
        end
        it 'sets $EXTRAOPTS to include the backend and frontend configs' do
          is_expected.to contain_file(file).with_content(
            %r{EXTRAOPTS="-f \/etc\/haproxy\/backends\.cfg -f \/etc\/haproxy\/frontends\.cfg"\n},
          )
        end
      end

      describe 'frontends config file' do
        let(:file) { frontend_file }

        it { is_expected.to contain_file(file).with(ensure: 'present') }
        it { is_expected.to contain_file(file).with(require: 'Package[haproxy]') }
        it { is_expected.to contain_file(file).with(notify: 'Service[haproxy]') }
        it { is_expected.to contain_file(file).with(mode: '0644') }

        it 'says it is managed by puppet' do
          is_expected.to contain_file(file).with_content(
            %r{\A# Managed by puppet \(nebula\/profile\/haproxy\/frontends\.cfg\.erb\)\n},
          )
        end

        [
          "frontend www-lib-hatcher-http-front\n" \
            "  bind 1.2.3.4:80,40.41.42.43:80\n" \
            "  stats uri \/haproxy?stats\n" \
            "  default_backend www-lib-hatcher-http-back\n" \
            "  http-request set-header X-Client-IP %ci\n" \
            "  http-request set-header X-Forwarded-Proto http\n",
          "frontend www-lib-hatcher-https-front\n" \
            "  bind 1.2.3.4:443,40.41.42.43:443 ssl crt /etc/ssl/private/www-lib\n" \
            "  stats uri /haproxy?stats\n" \
            "  default_backend www-lib-hatcher-https-back\n" \
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
      end

      describe 'backends config file' do
        let(:file) { backend_file }

        it { is_expected.to contain_file(file).with(ensure: 'present') }
        it { is_expected.to contain_file(file).with(require: 'Package[haproxy]') }
        it { is_expected.to contain_file(file).with(notify: 'Service[haproxy]') }
        it { is_expected.to contain_file(file).with(mode: '0644') }

        it 'says it is managed by puppet' do
          is_expected.to contain_file(file).with_content(
            %r{\A# Managed by puppet \(nebula\/profile\/haproxy\/backends\.cfg\.erb\)\n},
          )
        end

        [
          "backend www-lib-hatcher-http-back\n" \
            "  http-check expect status 200\n" \
            "  server scotch 111.111.111.123:80 check cookie s123\n" \
            "  server soda 222.222.222.234:80 check cookie s234\n",
          "backend www-lib-hatcher-https-back\n" \
            "  http-check expect status 200\n" \
            "  server scotch 111.111.111.123:443 check cookie s123\n" \
            "  server soda 222.222.222.234:443 check cookie s234\n",
        ].each do |stanza|
          it 'contains the stanza' do
            is_expected.to contain_file(file).with_content(%r{#{stanza}}m)
          end
        end
      end
    end
  end
end
