# frozen_string_literal: true

# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require "spec_helper"

describe "nebula::profile::client_cert_https" do
  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it "contains nginx with version numbers disabled on error pages" do
        is_expected.to contain_class("nginx").with_server_tokens("off")
      end

      it "contains an https proxy with client certs" do
        is_expected.to contain_nginx__resource__server("client_cert_https")
          .with_server_name([facts[:networking]["fqdn"]])
          .with_listen_options("default_server")
          .with_listen_port(443)
          .with_proxy("http://localhost:80")
          .with_ssl(true)
          .with_ssl_cert("/etc/nginx/tls/tls.crt")
          .with_ssl_key("/etc/nginx/tls/tls.key")
          .with_server_cfg_append(
            "ssl_client_certificate" => "/etc/nginx/tls/ca.crt",
            "ssl_verify_client" => "on",
            "ssl_verify_depth" => 1
          )
      end

      it "opens 443 to the world" do
        is_expected.to contain_firewall("200 HTTPS: client-cert protected unspecified http service")
          .with_proto("tcp")
          .with_dport([443])
          .with_source("0.0.0.0/0")
          .with_state("NEW")
          .with_jump("accept")
      end

      # This directory is created by the nginx module.
      it { is_expected.to contain_file("/etc/nginx").with_ensure("directory") }

      it { is_expected.to contain_file("/etc/nginx/tls").with_ensure("directory") }

      it do
        is_expected.to contain_file("/etc/nginx/tls/ca.crt")
          .with_mode("0644")
          .with_source("puppet:///pki/ca.crt")
          .that_requires("File[/etc/nginx/tls]")
          .that_notifies("Nginx::Resource::Server[client_cert_https]")
      end

      it do
        is_expected.to contain_file("/etc/nginx/tls/tls.crt")
          .with_mode("0644")
          .with_source("puppet:///pki/#{facts[:networking]["fqdn"]}.crt")
          .that_requires("File[/etc/nginx/tls]")
          .that_notifies("Nginx::Resource::Server[client_cert_https]")
      end

      it do
        is_expected.to contain_file("/etc/nginx/tls/tls.key")
          .with_mode("0400")
          .with_source("puppet:///pki/#{facts[:networking]["fqdn"]}.key")
          .that_requires("File[/etc/nginx/tls]")
          .that_notifies("Nginx::Resource::Server[client_cert_https]")
      end

      context "with http_port set to 1234" do
        let(:params) { {http_port: 1234} }

        it { is_expected.to contain_nginx__resource__server("client_cert_https").with_proxy("http://localhost:1234") }
      end

      context "with https_port set to 2468" do
        let(:params) { {https_port: 2468} }

        it { is_expected.to contain_nginx__resource__server("client_cert_https").with_listen_port(2468) }
        it { is_expected.to contain_firewall("200 HTTPS: client-cert protected unspecified http service").with_dport([2468]) }
      end

      context "with server_name set to any.example" do
        let(:params) { {server_name: "any.example"} }

        it { is_expected.to contain_nginx__resource__server("client_cert_https").with_server_name(["any.example"]) }
      end

      context "with allow_cidr set to 192.168.0.0/16" do
        let(:params) { {allow_cidr: "192.168.0.0/16"} }

        it { is_expected.to contain_firewall("200 HTTPS: client-cert protected unspecified http service").with_source("192.168.0.0/16") }
      end

      context "with certs_source_prefix set to https://any.example/pki" do
        let(:params) { {certs_source_prefix: "https://any.example/pki"} }

        it { is_expected.to contain_file("/etc/nginx/tls/ca.crt").with_source("https://any.example/pki/ca.crt") }
        it { is_expected.to contain_file("/etc/nginx/tls/tls.crt").with_source("https://any.example/pki/#{facts[:networking]["fqdn"]}.crt") }
        it { is_expected.to contain_file("/etc/nginx/tls/tls.key").with_source("https://any.example/pki/#{facts[:networking]["fqdn"]}.key") }
      end

      context "with ca_source set to https://any.example/ca.crt" do
        let(:params) { {ca_source: "https://any.example/ca.crt"} }

        it { is_expected.to contain_file("/etc/nginx/tls/ca.crt").with_source("https://any.example/ca.crt") }
        it { is_expected.to contain_file("/etc/nginx/tls/tls.crt").with_source("puppet:///pki/#{facts[:networking]["fqdn"]}.crt") }
        it { is_expected.to contain_file("/etc/nginx/tls/tls.key").with_source("puppet:///pki/#{facts[:networking]["fqdn"]}.key") }
      end

      context "with cert_source set to https://any.example/tls.crt" do
        let(:params) { {cert_source: "https://any.example/tls.crt"} }

        it { is_expected.to contain_file("/etc/nginx/tls/ca.crt").with_source("puppet:///pki/ca.crt") }
        it { is_expected.to contain_file("/etc/nginx/tls/tls.crt").with_source("https://any.example/tls.crt") }
        it { is_expected.to contain_file("/etc/nginx/tls/tls.key").with_source("puppet:///pki/#{facts[:networking]["fqdn"]}.key") }
      end

      context "with key_source set to https://any.example/tls.key" do
        let(:params) { {key_source: "https://any.example/tls.key"} }

        it { is_expected.to contain_file("/etc/nginx/tls/ca.crt").with_source("puppet:///pki/ca.crt") }
        it { is_expected.to contain_file("/etc/nginx/tls/tls.crt").with_source("puppet:///pki/#{facts[:networking]["fqdn"]}.crt") }
        it { is_expected.to contain_file("/etc/nginx/tls/tls.key").with_source("https://any.example/tls.key") }
      end

      context "with http_service_name set to my cool app" do
        let(:params) { {http_service_name: "my cool app"} }

        it { is_expected.to contain_firewall("200 HTTPS: client-cert protected my cool app") }
      end
    end
  end
end
