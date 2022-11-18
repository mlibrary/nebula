# frozen_string_literal: true

# Copyright (c) 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::certbot_route53' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it { is_expected.to contain_package("certbot") }
      it { is_expected.to contain_package("awscli") }
      it { is_expected.to contain_package("python3-certbot-dns-route53") }

      it { is_expected.to contain_file("/root/.aws").with_ensure("directory") }

      it do
        is_expected.to contain_file("/root/.aws/config")
          .with_mode("0600")
          .that_requires("File[/root/.aws]")
      end

      it do
        is_expected.to contain_file("/root/.aws/credentials")
          .with_mode("0600")
          .that_requires("File[/root/.aws]")
          .with_content(
            <<~EOF
              [default]
              aws_access_key_id = default.invalid
              aws_secret_access_key = default.invalid
            EOF
          )
      end

      context "with a single cert" do
        let(:params) do
          {
            certs: { "onlyservice" => { "example.invalid" => [] } },
            cert_dir: "/certs",
            haproxy_cert_dir: "/haproxy",
            letsencrypt_email: "our_real_email@email.gov",
            aws_access_key_id: "ACCESSKEY",
            aws_secret_access_key: "SECRETKEY"
          }
        end

        it { is_expected.to compile }

        it do
          is_expected.to contain_file("/root/.aws/credentials")
            .with_content(
              <<~EOF
                [default]
                aws_access_key_id = ACCESSKEY
                aws_secret_access_key = SECRETKEY
              EOF
            )
        end

        it do
          is_expected.to contain_file("/tmp/all_cert_commands")
            .with_content(
              <<~EOF
                certbot certonly --dns-route53 -m "our_real_email@email.gov" -d "example.invalid,*.example.invalid"
              EOF
            )
        end

        it do
          is_expected.to contain_file("/certs/example.invalid.crt")
            .with_group("puppet")
            .with_source("/etc/letsencrypt/live/example.invalid/fullchain.pem")
        end

        it do
          is_expected.to contain_file("/certs/example.invalid.key")
            .with_group("puppet")
            .with_source("/etc/letsencrypt/live/example.invalid/privkey.pem")
        end

        it do
          is_expected.to contain_concat("/haproxy/onlyservice/example.invalid.pem")
            .with_group("puppet")
        end

        it do
          is_expected.to contain_concat_fragment("example.invalid.pem cert")
            .with_order("01")
            .with_target("/haproxy/onlyservice/example.invalid.pem")
            .with_source("/etc/letsencrypt/live/example.invalid/fullchain.pem")
        end

        it do
          is_expected.to contain_concat_fragment("example.invalid.pem key")
            .with_order("02")
            .with_target("/haproxy/onlyservice/example.invalid.pem")
            .with_source("/etc/letsencrypt/live/example.invalid/privkey.pem")
        end
      end

      context "with a multiple certs and services" do
        let(:params) do
          {
            certs: {
              "a" => { "abc.invalid" => %w[abc.example] },
              "z" => { "zyx.invalid" => [] }
            }
          }
        end

        it do
          is_expected.to contain_file("/tmp/all_cert_commands")
            .with_content(
              <<~EOF
                certbot certonly --dns-route53 -m "nope@nope.zone" -d "abc.invalid,*.abc.invalid,abc.example,*.abc.example"
                certbot certonly --dns-route53 -m "nope@nope.zone" -d "zyx.invalid,*.zyx.invalid"
              EOF
            )
        end

        it { is_expected.to compile }
        it { is_expected.to contain_file("/var/local/cert_dir/abc.invalid.crt") }
        it { is_expected.to contain_file("/var/local/cert_dir/abc.example.crt") }
        it { is_expected.to contain_file("/var/local/cert_dir/zyx.invalid.crt") }
        it { is_expected.to contain_file("/var/local/cert_dir/abc.invalid.key") }
        it { is_expected.to contain_file("/var/local/cert_dir/abc.example.key") }
        it { is_expected.to contain_file("/var/local/cert_dir/zyx.invalid.key") }
        it { is_expected.to contain_concat("/var/local/haproxy_cert_dir/a/abc.invalid.pem") }
        it { is_expected.to contain_concat("/var/local/haproxy_cert_dir/a/abc.example.pem") }
        it { is_expected.to contain_concat("/var/local/haproxy_cert_dir/z/zyx.invalid.pem") }
        it { is_expected.to contain_concat_fragment("abc.invalid.pem cert") }
        it { is_expected.to contain_concat_fragment("abc.example.pem cert") }
        it { is_expected.to contain_concat_fragment("zyx.invalid.pem cert") }
        it { is_expected.to contain_concat_fragment("abc.invalid.pem key") }
        it { is_expected.to contain_concat_fragment("abc.example.pem key") }
        it { is_expected.to contain_concat_fragment("zyx.invalid.pem key") }
      end
    end
  end
end
