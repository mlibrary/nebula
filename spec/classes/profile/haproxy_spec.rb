# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::haproxy' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge(
          datacenter: "hatcher",
          networking: {
            ip: "40.41.42.43"
          }
        )
      end
      let(:scotch) {{ 'ip' => "111.111.111.123", 'hostname' => "scotch"  }}
      let(:soda)   {{ 'ip' => "222.222.222.234", 'hostname' => "soda"  }}
      let(:params) {{floating_ip: '1.2.3.4'}}

      let!(:nodes_for_role) do
        MockFunction.new('nodes_for_role') do |f|
          f.stubbed.with('nebula::role::webhost::www_lib')
            .returns(["rolenode", "scotch", "soda"])
        end
      end

      let!(:nodes_for_datacenter) do
        MockFunction.new('nodes_for_datacenter') do |f|
          f.stubbed.with("hatcher")
            .returns(["dcnode", "scotch", "anotherdcnode", "soda"])
        end
      end

      let!(:fact_for) do
        MockFunction.new('fact_for') do |f|
          f.stubbed.with('scotch', 'networking').returns(scotch)
          f.stubbed.with('soda', 'networking').returns(soda)
        end
      end

      describe "services" do
        it do
          is_expected.to contain_service('haproxy').with(
            ensure: 'running',
            enable: true,
            hasrestart: true
          )
        end
      end

      describe "packages" do
        it { is_expected.to contain_package('haproxy') }
        it { is_expected.to contain_package('haproxyctl') }
      end

      describe '/etc/haproxy/haproxy.cfg' do
        let(:file) { '/etc/haproxy/haproxy.cfg' }
        it { is_expected.to contain_file(file).with(ensure: 'present') }
        it { is_expected.to contain_file(file).with(require: 'Package[haproxy]') }
        it { is_expected.to contain_file(file).with(notify: 'Service[haproxy]') }
        it { is_expected.to contain_file(file).with(mode: '0644') }

        it "says it is managed by puppet" do
          is_expected.to contain_file(file).with_content(
            /\A# Managed by puppet \(nebula\/profile\/haproxy\/haproxy\.cfg\.erb\)\n/
          )
        end
        it "has a global section" do
          is_expected.to contain_file(file).with_content(/^global\n/)
        end
        it "has a defaults section" do
          is_expected.to contain_file(file).with_content(/^defaults\n/)
        end
        it "does not have a backend section" do
          is_expected.to_not contain_file(file).with_content(/^backend\W+.*\n/)
        end
        it "does not have a frontend section" do
          is_expected.to_not contain_file(file).with_content(/^frontend\W+.*\n/)
        end
      end

      # TODO: /etc/default/haproxy must be configured

      describe '/etc/haproxy/frontends.cfg' do
        let(:file) { '/etc/haproxy/frontends.cfg' }
        it { is_expected.to contain_file(file).with(ensure: 'present') }
        it { is_expected.to contain_file(file).with(require: 'Package[haproxy]') }
        it { is_expected.to contain_file(file).with(notify: 'Service[haproxy]') }
        it { is_expected.to contain_file(file).with(mode: '0644') }

        it "says it is managed by puppet" do
          is_expected.to contain_file(file).with_content(
            /\A# Managed by puppet \(nebula\/profile\/haproxy\/frontends\.cfg\.erb\)\n/
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
            "  http-request set-header X-Forwarded-Proto https\n"
        ].each do |stanza|
          it "contains the stanza" do
            is_expected.to contain_file(file)
            actual = catalogue.resource('file', file).send(:parameters)[:content]
            expect(actual).to include(stanza)
          end
        end

      end

      describe '/etc/haproxy/backends.cfg' do
        let(:file) { '/etc/haproxy/backends.cfg' }
        it { is_expected.to contain_file(file).with(ensure: 'present') }
        it { is_expected.to contain_file(file).with(require: 'Package[haproxy]') }
        it { is_expected.to contain_file(file).with(notify: 'Service[haproxy]') }
        it { is_expected.to contain_file(file).with(mode: '0644') }

        it "says it is managed by puppet" do
          is_expected.to contain_file(file).with_content(
            /\A# Managed by puppet \(nebula\/profile\/haproxy\/backends\.cfg\.erb\)\n/
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
          it "contains the stanza" do
            is_expected.to contain_file(file).with_content(/#{stanza}/m)
          end
        end
      end

    end
  end
end
