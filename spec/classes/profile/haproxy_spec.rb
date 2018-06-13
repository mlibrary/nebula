# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::haproxy' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      file = '/etc/haproxy/haproxy.cfg'
      let(:facts) { os_facts.merge(datacenter: "hatcher") }
      let(:scotch) {{ 'ip' => "111.111.111.123", 'hostname' => "scotch"  }}
      let(:soda)   {{ 'ip' => "222.222.222.234", 'hostname' => "soda"  }}

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

      it 'contains the service' do
        is_expected.to contain_service('haproxy').with(
          ensure: 'running',
          enable: true,
          hasrestart: true
        )
      end

      it 'contains the package' do
        is_expected.to contain_package('haproxy')
      end


      describe file do
        it { is_expected.to contain_file(file).with(ensure: 'present') }
        it { is_expected.to contain_file(file).with(require: 'Package[haproxy]') }
        it { is_expected.to contain_file(file).with(notify: 'Service[haproxy]') }
        it { is_expected.to contain_file(file).with(mode: '0644') }

        [
        "backend www-lib-hatcher-http-back\n" \
          "http-check expect status 200\n" \
          "server scotch 111.111.111.123:80 check cookie s123\n" \
          "server soda 222.222.222.234:80 check cookie s234\n",
        "backend www-lib-hatcher-https-back\n" \
          "http-check expect status 200\n" \
          "server scotch 111.111.111.123:443 check cookie s123\n" \
          "server soda 222.222.222.234:443 check cookie s234\n",
        ].each do |stanza|
          it "contains the stanza" do
            is_expected.to contain_file(file).with_content(/#{stanza}/m)
          end
        end
      end

    end
  end
end
