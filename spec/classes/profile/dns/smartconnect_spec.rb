# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::dns::smartconnect' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it do
        is_expected.to contain_package(
          'nebula::profile::dns::smartconnect::bind9',
        ).with_name('bind9').with_ensure('present')
      end

      it do
        is_expected.to contain_service('bind9').with_ensure('running')
      end

      it do
        is_expected.to contain_class('resolv_conf').with_nameservers(
          [
            '127.0.0.1',  # localhost
            '5.5.5.5',    # nebula::resolv_conf::nameservers[0]
            '4.4.4.4',    # nebula::resolv_conf::nameservers[1]
          ],
        ).with_searchpath(['searchpath.default.invalid'])
                                                   .with_require('Service[bind9]')
      end

      [
        '/etc/bind/named.conf',
        '/etc/bind/named.conf.local',
        '/etc/bind/named.conf.options',
      ].each do |name|
        it { is_expected.to contain_file(name).with_notify('Service[bind9]') }
      end

      it do
        is_expected.to contain_file('/etc/bind/named.conf').with_content(
          %r{/etc/bind/named.conf.options},
        ).with_content(
          %r{/etc/bind/named.conf.local},
        )
      end

      [
        %r{^zone "localhost" \{[^\}]*type master;[^\}]*file "/etc/bind/db\.local";$}m,
        %r{^zone "127\.in-addr\.arpa" \{[^\}]*type master;[^\}]*file "/etc/bind/db\.127";$}m,
        %r{^zone "0\.in-addr\.arpa" \{[^\}]*type master;[^\}]*file "/etc/bind/db\.0";$}m,
        %r{^zone "255\.in-addr\.arpa" \{[^\}]*type master;[^\}]*file "/etc/bind/db\.255";$}m,
        %r{^zone "smartconnect\.default\.invalid" \{[^\}]*type forward;[^\}]*forward only;[^\}]*1\.2\.3\.4;$}m,
      ].each do |content|
        it { is_expected.to contain_file('/etc/bind/named.conf.local').with_content(content) }
      end

      it do
        is_expected.to contain_file('/etc/bind/named.conf.options').with_content(
          %r{^\s*5\.5\.5\.5; 4\.4\.4\.4;$},
        )
      end

      context 'when given other_ns_ips' do
        let(:params) { { other_ns_ips: ['3.3.3.3', '2.2.2.2', '1.1.1.1'] } }

        it do
          is_expected.to contain_class('resolv_conf').with_nameservers(
            [
              '127.0.0.1',
              '3.3.3.3',
              '2.2.2.2',
              '1.1.1.1',
            ],
          ).with_searchpath(['searchpath.default.invalid'])
        end

        it do
          is_expected.to contain_file('/etc/bind/named.conf.options').with_content(
            %r{^\s*3\.3\.3\.3; 2\.2\.2\.2; 1\.1\.1\.1;$},
          )
        end
      end
    end
  end
end
