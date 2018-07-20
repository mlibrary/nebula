# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'
require_relative '../../support/contexts/with_mocked_nodes'

describe 'nebula::profile::haproxy' do
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

      let(:default_file) { '/etc/default/haproxy' }
      let(:haproxy_conf) { '/etc/haproxy/haproxy.cfg' }
      let(:keepalived_conf) { '/etc/keepalived/keepalived.conf' }
      let(:service) { 'keepalived' }

      let(:thisnode) { { 'ip' => facts[:networking][:ip], 'hostname' => facts[:hostname] } }
      let(:haproxy2) { { 'ip' => Faker::Internet.ip_v4_address, 'hostname' => 'haproxy2' } }
      let(:scotch) { { 'ip' => '111.111.111.123', 'hostname' => 'scotch' } }
      let(:soda)   { { 'ip' => '222.222.222.234', 'hostname' => 'soda' } }
      let(:third_server) { { 'ip' => '333.333.333.345', 'hostname' => 'third_server' } }
      let(:params) { { cert_source: '/some/where' } }

      include_context 'with mocked puppetdb functions', 'somedc', %w[thisnode haproxy2 scotch soda third_server], 'nebula::profile::haproxy' => %w[thisnode haproxy2]

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

        it do
          is_expected.to contain_nebula__haproxy_service('svc1').with(
            floating_ip: '12.23.32.22',
            node_names: %w[scotch soda],
            cert_source: '/some/where',
            max_requests_per_sec: 10,
            max_requests_burst: 200,
          )
        end

        it do
          is_expected.to contain_nebula__haproxy_service('svc2').with(
            floating_ip: '12.23.32.23',
            node_names: %w[scotch third_server],
            cert_source: '/some/where',
          )
        end
      end

      describe 'packages' do
        it { is_expected.to contain_package('haproxy') }
        it { is_expected.to contain_package('haproxyctl') }
        it { is_expected.to contain_package('keepalived') }
        it { is_expected.to contain_package('ipset') }
      end

      describe 'users' do
        it { is_expected.to contain_user('haproxyctl').with(name: 'haproxyctl', gid: 'haproxy', managehome: true, home: '/var/haproxyctl') }

        it 'grants ssh access to the monitoring user' do
          is_expected.to contain_file('/var/haproxyctl/.ssh/authorized_keys')
            .with_content(%r{^ecdsa-sha2-nistp256 CCCCCCCCCCCC haproxyctl@default\.invalid$})
        end
      end

      describe 'service' do
        it { is_expected.to contain_service(service).that_requires('Package[keepalived]') }
        it { is_expected.to contain_service(service).with(enable: true) }
        it { is_expected.to contain_service(service).with(ensure: 'running') }
      end

      describe 'haproxy default file' do
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
          is_expected.to contain_file(file).with_content(%r{^CONFIG="#{haproxy_conf}"\n})
        end

        it 'sets $EXTRAOPTS to include the service directory' do
          is_expected.to contain_file(file).with_content(
            %r{EXTRAOPTS="-f \/etc\/haproxy\/services.d"\n},
          )
        end
      end

      describe 'base haproxy config file' do
        let(:file) { haproxy_conf }

        it { is_expected.to contain_file(file).with(ensure: 'present') }
        it { is_expected.to contain_file(file).with(require: 'Package[haproxy]') }
        it { is_expected.to contain_file(file).with(notify: 'Service[haproxy]') }
        it { is_expected.to contain_file(file).with(mode: '0644') }
        it { is_expected.to contain_file('/etc/haproxy/services.d').with(ensure: 'directory') }

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

      describe 'base keepalived config file' do
        let(:file) { keepalived_conf }

        it { is_expected.to contain_file(file).with(ensure: 'present') }
        it { is_expected.to contain_file(file).with(require: 'Package[keepalived]') }
        it { is_expected.to contain_file(file).with(notify: 'Service[keepalived]') }
        it { is_expected.to contain_file(file).with(mode: '0644') }

        it 'has a vrrp_scripts check_haproxy section' do
          is_expected.to contain_file(file).with_content(%r{^vrrp_script check_haproxy})
        end

        it 'has the haproxy floating ip addresses' do
          is_expected.to contain_file(file).with_content(%r{virtual_ipaddress {\n\s*12\.23\.32\.22\n\s*12\.23\.32\.23\n\s*}}m)
        end

        context 'with a floating ip address parameter' do
          let(:params) do
            {
              services: { 'svc1' => { 'floating_ip' => Faker::Internet.ip_v4_address },
                          'svc2' => { 'floating_ip' => Faker::Internet.ip_v4_address } },
            }
          end

          it { is_expected.to contain_file(file).with_content(%r{virtual_ipaddress {\n\s*#{params[:services]["svc1"]["floating_ip"]}\n\s*#{params[:services]["svc2"]["floating_ip"]}\n\s*}}m) }
        end

        it { is_expected.to contain_file(file).with_content(%r{unicast_src_ip #{my_ip}}) }

        it 'has a unicast_peer block with the IP addresses of all nodes with the same profile at the same datancenter except for me' do
          is_expected.to contain_file(file).with_content(%r{unicast_peer {\n\s*#{haproxy2['ip']}\n\s*}\n\s*})
        end

        it { is_expected.to contain_file(file).with_content(%r{interface #{facts[:networking][:primary]}}) }

        it { is_expected.to contain_file(file).with_content(%r{notification_email {\n\s.*root@default.invalid\n\s.*}}m) }
        it { is_expected.to contain_file(file).with_content(%r{notification_email_from root@default.invalid}) }

        context 'on a master node' do
          let(:params) { { master: true } }

          it { is_expected.to contain_file(file).with_content(%r{priority 101}) }
          it { is_expected.to contain_file(file).with_content(%r{state MASTER}) }
        end

        context 'on a backup node' do
          let(:params) { { master: false } }

          it { is_expected.to contain_file(file).with_content(%r{priority 100}) }
          it { is_expected.to contain_file(file).with_content(%r{state BACKUP}) }
        end
      end

      describe 'sysctl conf' do
        let(:file) { '/etc/sysctl.d/keepalived.conf' }

        it { is_expected.to contain_file(file).with(ensure: 'present') }
        it { is_expected.to contain_file(file).with(mode: '0644') }

        it 'says it is managed by puppet' do
          is_expected.to contain_file(file).with_content(
            %r{\A# Managed by puppet},
          )
        end

        it 'enables ip_nonlocal_bind' do
          is_expected.to contain_file(file).with_content(%r{^net.ipv4.ip_nonlocal_bind = 1$})
        end
      end
    end
  end
end
