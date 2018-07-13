# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'
require_relative '../../support/contexts/with_mocked_nodes'

describe 'nebula::profile::haproxy' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:default_file) { '/etc/default/haproxy' }
      let(:base_file) { '/etc/haproxy/haproxy.cfg' }
      let(:svc1_file) { '/etc/haproxy/svc1.cfg' }
      let(:svc2_file) { '/etc/haproxy/svc2.cfg' }

      let(:scotch) { { 'ip' => '111.111.111.123', 'hostname' => 'scotch' } }
      let(:soda)   { { 'ip' => '222.222.222.234', 'hostname' => 'soda' } }
      let(:third_server) { { 'ip' => '333.333.333.345', 'hostname' => 'third_server' } }
      let(:params) do
        { floating_ips: { 'svc1' => '1.2.3.4', 'svc2' => '1.2.3.5' },
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

      before(:each) do
        stub('balanced_frontends') do |d|
          allow_call(d).and_return('svc1' => %w[scotch soda], 'svc2' => %w[scotch third_server])
        end
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
        it 'configures the admin socket in the correct place with group privileges' do
          is_expected.to contain_file(file).with_content(%r{stats socket /run/haproxy/admin.sock mode 660 level admin})
        end
        it 'runs with the haproxy group' do
          is_expected.to contain_file(file).with_content(%r{group haproxy})
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
        it 'sets $EXTRAOPTS to include the service configs' do
          is_expected.to contain_file(file).with_content(
            %r{EXTRAOPTS="-f \/etc\/haproxy\/svc1\.cfg -f \/etc\/haproxy\/svc2\.cfg "\n},
          )
        end
      end

      describe 'svc1 config file' do
        let(:service) { 'svc1' }
        let(:file) { svc1_file }

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

      context "svc2 config file" do
        let(:service) { 'svc2' }
        let(:file) { svc2_file }

        it { is_expected.to contain_file(file).with(ensure: 'present') }
        it { is_expected.to contain_file(file).with(require: 'Package[haproxy]') }
        it { is_expected.to contain_file(file).with(notify: 'Service[haproxy]') }
        it { is_expected.to contain_file(file).with(mode: '0644') }

        it 'says it is managed by puppet' do
          is_expected.to contain_file(file).with_content(
            %r{\A# Managed by puppet \(nebula\/profile\/haproxy\/service\.cfg\.erb\)\n},
          )
        end

        it 'contains the stanza backend svc2-hatcher-http-back' do
          is_expected.to contain_file(file).with_content(%r{#{
            "backend svc2-hatcher-http-back\n" \
            "  http-check expect status 200\n" \
            "  server scotch 111.111.111.123:80 check cookie s123\n" \
            "  server #{third_server["hostname"]} #{third_server["ip"]}:80 check cookie s#{third_server["ip"].split('.').last}\n" \
          }}m)
        end

        it 'contains the stanza backend svc2-hatcher-https-back' do
          is_expected.to contain_file(file).with_content(%r{#{
            "backend svc2-hatcher-https-back\n" \
            "  http-check expect status 200\n" \
            "  server scotch 111.111.111.123:443 check cookie s123\n" \
            "  server #{third_server["hostname"]} #{third_server["ip"]}:443 check cookie s#{third_server["ip"].split('.').last}\n" \
          }}m)
        end
      end

      describe 'ssl certs' do
        let(:dest) { '/etc/ssl/private/svc1' }

        context 'with an empty source' do
          it { is_expected.not_to contain_file(dest) }
        end

        context 'with a source' do
          let(:params) do
            { floating_ips: { 'svc1': '1.2.3.4' },
              cert_source: '/some/location' }
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

      describe 'users' do
        it { is_expected.to contain_user('haproxyctl').with(name: 'haproxyctl', gid: 'haproxy', managehome: true, home: '/var/haproxyctl') }

        it 'grants ssh access to the monitoring user' do
          is_expected.to contain_file('/var/haproxyctl/.ssh/authorized_keys')
            .with_content(%r{^ecdsa-sha2-nistp256 CCCCCCCCCCCC haproxyctl@default\.invalid$})
        end
      end
    end
  end
end
