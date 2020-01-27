# frozen_string_literal: true

# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::https_to_port' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:server_name) { facts[:fqdn] }
      let(:letsencrypt_directory) { "/etc/letsencrypt/live/#{server_name}" }

      context 'when port is set to 1234' do
        let(:params) { { port: 1234 } }

        it { is_expected.to compile }

        it { is_expected.to contain_class('nginx') }

        it do
          is_expected.to contain_nginx__resource__server('letsencrypt-webroot')
            .with_server_name([server_name])
            .with_listen_port(80)
            .with_www_root('/var/www')
        end

        it do
          is_expected.to contain_nebula__cert(server_name)
            .with_webroot('/var/www')
            .that_requires('Nginx::Resource::Server[letsencrypt-webroot]')
        end

        it do
          is_expected.to contain_nginx__resource__server('https-forwarder')
            .with_server_name([server_name])
            .with_listen_port(443)
            .with_proxy('http://localhost:1234')
            .with_ssl(true)
            .with_ssl_cert("#{letsencrypt_directory}/fullchain.pem")
            .with_ssl_key("#{letsencrypt_directory}/privkey.pem")
            .that_requires("Nebula::Cert[#{server_name}]")
        end

        context 'and server_name is set to example.invalid' do
          let(:server_name) { 'example.invalid' }
          let(:params) do
            super().merge(server_name: server_name)
          end

          it do
            is_expected.to contain_nginx__resource__server('letsencrypt-webroot')
              .with_server_name([server_name])
          end

          it do
            is_expected.to contain_nebula__cert(server_name)
          end

          it do
            is_expected.to contain_nginx__resource__server('https-forwarder')
              .with_server_name([server_name])
              .with_ssl_cert("#{letsencrypt_directory}/fullchain.pem")
              .with_ssl_key("#{letsencrypt_directory}/privkey.pem")
              .that_requires("Nebula::Cert[#{server_name}]")
          end
        end

        context "and server_name is set to something that doesn't have keys yet" do
          let(:server_name) { 'nokeysyet.invalid' }
          let(:params) do
            super().merge(server_name: server_name)
          end

          it { is_expected.not_to contain_nginx__resource__server('https-forwarder') }
        end

        context 'and webroot is set to /opt/html' do
          let(:params) do
            super().merge(webroot: '/opt/html')
          end

          it do
            is_expected.to contain_nginx__resource__server('letsencrypt-webroot')
              .with_www_root('/opt/html')
          end

          it do
            is_expected.to contain_nebula__cert(server_name)
              .with_webroot('/opt/html')
          end
        end
      end

      context 'when port is set to 2468' do
        let(:params) { { port: 2468 } }

        it do
          is_expected.to contain_nginx__resource__server('https-forwarder')
            .with_proxy('http://localhost:2468')
        end
      end
    end
  end
end
