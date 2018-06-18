# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::keepalived' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:my_ip) { Faker::Internet.ip_v4_address }
      let(:facts) do
        os_facts.merge(
          datacenter: 'somedc',
          networking: {
            ip: my_ip,
            primary: 'eth0',
          },
          hostname: 'thisnode',
        )
      end

      let(:thisnode) { { 'ip' => facts[:networking][:ip], 'hostname' => facts[:hostname] } }
      let(:scotch) { { 'ip' => Faker::Internet.ip_v4_address, 'hostname' => 'scotch' } }
      let(:soda)   { { 'ip' => Faker::Internet.ip_v4_address, 'hostname' => 'soda' } }

      let!(:nodes_for_role) do
        MockFunction.new('nodes_for_role') do |f|
          f.stubbed.with('nebula::profile::keepalived')
           .returns(%w[thisnode other_dc_keepalive_node scotch soda])
        end
      end

      let!(:nodes_for_datacenter) do
        MockFunction.new('nodes_for_datacenter') do |f|
          f.stubbed.with(facts[:datacenter])
           .returns(%w[thisnode dcnode scotch anotherdcnode soda])
        end
      end

      let!(:fact_for) do
        MockFunction.new('fact_for') do |f|
          f.stubbed.with('scotch', 'networking').returns(scotch)
          f.stubbed.with('soda', 'networking').returns(soda)
          f.stubbed.with('thisnode', 'networking').returns(thisnode)
        end
      end

      let(:base_file) { '/etc/keepalived/keepalived.conf' }
      let(:service) { 'keepalived' }

      describe 'packages' do
        it { is_expected.to contain_package('keepalived') }
        it { is_expected.to contain_package('ipset') }
      end

      describe 'base config file' do
        let(:file) { base_file }

        it { is_expected.to contain_file(file).with(ensure: 'present') }
        it { is_expected.to contain_file(file).with(require: 'Package[keepalived]') }
        it { is_expected.to contain_file(file).with(notify: 'Service[keepalived]') }
        it { is_expected.to contain_file(file).with(mode: '0644') }

        it 'has a vrrp_scripts check_haproxy section' do
          is_expected.to contain_file(file).with_content(%r{^vrrp_script check_haproxy})
        end

        it 'has the haproxy floating ip address' do
          is_expected.to contain_file(file).with_content(%r{virtual_ipaddress {\n\s*12\.23\.32\.22\n\s*}}m)
        end

        context 'with a floating ip address parameter' do
          let(:params) { { floating_ip: Faker::Internet.ip_v4_address } }

          it { is_expected.to contain_file(file).with_content(%r{virtual_ipaddress {\n\s*#{params[:floating_ip]}\n\s*}}m) }
        end

        it { is_expected.to contain_file(file).with_content(%r{unicast_src_ip #{my_ip}}) }

        it 'has a unicast_peer block with the IP addresses of all nodes with the same profile at the same datancenter except for me' do
          is_expected.to contain_file(file).with_content(%r{unicast_peer {\n\s*#{scotch['ip']}\n\s*#{soda['ip']}\n\s*}})
        end

        it { is_expected.to contain_file(file).with_content(%r{interface #{facts[:networking][:primary]}}) }

        it { is_expected.to contain_file(file).with_content(%r{notification_email {\n\s.*root@default.invalid\n\s.*}}m) }
        it { is_expected.to contain_file(file).with_content(%r{notification_email_from root@default.invalid}) }
      end

      describe 'service' do
        it { is_expected.to contain_service(service).that_requires('Package[keepalived]') }
        xit { is_expected.to contain_service(service).that_requires('Package[haproxyctl]') }
        it { is_expected.to contain_service(service).with(enable: true) }
        it { is_expected.to contain_service(service).with(ensure: 'running') }
      end
    end
  end
end
