# frozen_string_literal: true

# Copyright (c) 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::certbot_cloudflare' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it { is_expected.to contain_package("certbot") }
      it { is_expected.to contain_package("python3-certbot-dns-cloudflare") }

      it { is_expected.to contain_file("/root/.secrets/certbot").with_ensure("directory") }

      it do
        is_expected.to contain_file("/root/.secrets/certbot/cloudflare.ini")
          .with_mode("0600")
          .that_requires("File[/root/.secrets/certbot]")
          .with_content(
            <<~EOF
              dns_cloudflare_api_token = default.invalid
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
            cloudflare_api_token: "MYTOKEN"
          }
        end

        it { is_expected.to compile }

        it do
          is_expected.to contain_file("/root/.secrets/certbot/cloudflare.ini")
            .with_content(
              <<~EOF
                dns_cloudflare_api_token = MYTOKEN
              EOF
            )
        end

        it do
          is_expected.to contain_file("/tmp/all_cert_commands_cloudflare")
            .with_content(
              <<~EOF
                certbot certonly --dns-cloudflare --dns-cloudflare-credentials ~/.secrets/certbot/cloudflare.ini -m "our_real_email@email.gov" -d "example.invalid,*.example.invalid"
              EOF
            )
        end

        it { is_expected.to contain_concat("/certs/example.invalid.crt").with_group("puppet") }
        it { is_expected.to contain_concat("/certs/example.invalid.key").with_group("puppet") }
        it { is_expected.to contain_concat("/haproxy/onlyservice/example.invalid.pem").with_group("puppet") }

        it do
          is_expected.to contain_concat_fragment("example.invalid.crt cert")
            .with_target("/certs/example.invalid.crt")
            .with_source("/etc/letsencrypt/live/example.invalid/fullchain.pem")
        end

        it do
          is_expected.to contain_concat_fragment("example.invalid.key key")
            .with_target("/certs/example.invalid.key")
            .with_source("/etc/letsencrypt/live/example.invalid/privkey.pem")
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
              "a" => { "abc.invalid" => %w[abc.example], "abc.com" => [] },
              "z" => { "zyx.invalid" => [] }
            }
          }
        end

        it do
          is_expected.to contain_file("/tmp/all_cert_commands_cloudflare")
            .with_content(
              <<~EOF
                certbot certonly --dns-cloudflare --dns-cloudflare-credentials ~/.secrets/certbot/cloudflare.ini -m "nope@nope.zone" -d "abc.invalid,*.abc.invalid,abc.example,*.abc.example"
                certbot certonly --dns-cloudflare --dns-cloudflare-credentials ~/.secrets/certbot/cloudflare.ini -m "nope@nope.zone" -d "abc.com,*.abc.com"
                certbot certonly --dns-cloudflare --dns-cloudflare-credentials ~/.secrets/certbot/cloudflare.ini -m "nope@nope.zone" -d "zyx.invalid,*.zyx.invalid"
              EOF
            )
        end

        it { is_expected.to compile }

        it { is_expected.to contain_concat("/var/local/cert_dir/abc.invalid.crt") }
        it { is_expected.to contain_concat("/var/local/cert_dir/abc.invalid.key") }
        it { is_expected.to contain_concat("/var/local/haproxy_cert_dir/a/abc.invalid.pem") }
        it { is_expected.to contain_concat_fragment("abc.invalid.crt cert") }
        it { is_expected.to contain_concat_fragment("abc.invalid.key key") }
        it { is_expected.to contain_concat_fragment("abc.invalid.pem cert") }
        it { is_expected.to contain_concat_fragment("abc.invalid.pem key") }

        it { is_expected.to contain_concat("/var/local/cert_dir/abc.com.crt") }
        it { is_expected.to contain_concat("/var/local/cert_dir/abc.com.key") }
        it { is_expected.to contain_concat("/var/local/haproxy_cert_dir/a/abc.com.pem") }
        it { is_expected.to contain_concat_fragment("abc.com.crt cert") }
        it { is_expected.to contain_concat_fragment("abc.com.key key") }
        it { is_expected.to contain_concat_fragment("abc.com.pem cert") }
        it { is_expected.to contain_concat_fragment("abc.com.pem key") }

        it { is_expected.to contain_concat("/var/local/cert_dir/zyx.invalid.crt") }
        it { is_expected.to contain_concat("/var/local/cert_dir/zyx.invalid.key") }
        it { is_expected.to contain_concat("/var/local/haproxy_cert_dir/z/zyx.invalid.pem") }
        it { is_expected.to contain_concat_fragment("zyx.invalid.crt cert") }
        it { is_expected.to contain_concat_fragment("zyx.invalid.key key") }
        it { is_expected.to contain_concat_fragment("zyx.invalid.pem cert") }
        it { is_expected.to contain_concat_fragment("zyx.invalid.pem key") }

        it { is_expected.not_to contain_concat("/var/local/cert_dir/abc.example.crt") }
        it { is_expected.not_to contain_concat("/var/local/cert_dir/abc.example.key") }
        it { is_expected.not_to contain_concat("/var/local/haproxy_cert_dir/a/abc.example.pem") }
        it { is_expected.not_to contain_concat_fragment("abc.example.crt cert") }
        it { is_expected.not_to contain_concat_fragment("abc.example.key key") }
        it { is_expected.not_to contain_concat_fragment("abc.example.pem cert") }
        it { is_expected.not_to contain_concat_fragment("abc.example.pem key") }
      end

      context "with one simple cert, no SANs" do
        let(:params) do
          {
            simple_certs: {
              "abc.example": []
            }
          }
        end

        it { is_expected.to compile }

        it do
          is_expected.to contain_file("/tmp/all_cert_commands_cloudflare")
            .with_content(%r{certbot certonly --dns-cloudflare --dns-cloudflare-credentials ~/.secrets/certbot/cloudflare.ini -m "nope@nope.zone" -d "abc.example"})
        end

        it do
          is_expected.to contain_concat_fragment("/var/local/cert_dir/abc.example.crt cert")
            .with_target("/var/local/cert_dir/abc.example.crt")
            .with_source("/etc/letsencrypt/live/abc.example/fullchain.pem")
        end

        it do
          is_expected.to contain_concat_fragment("/var/local/cert_dir/abc.example.key key")
            .with_target("/var/local/cert_dir/abc.example.key")
            .with_source("/etc/letsencrypt/live/abc.example/privkey.pem")
        end
      end

      context "with one simple cert, two SANs" do
        let(:params) do
          {
            simple_certs: {
              "abc.example": ['san.local','xyz.local']
            }
          }
        end

        it do
          is_expected.to contain_file("/tmp/all_cert_commands_cloudflare")
            .with_content(
              <<~EOF
              certbot certonly --dns-cloudflare --dns-cloudflare-credentials ~/.secrets/certbot/cloudflare.ini -m "nope@nope.zone" -d "abc.example,san.local,xyz.local"
              EOF
            )
        end
      end

      context "with two simple certs" do
        let(:params) do
          {
            simple_certs: {
              "abc.example": [],
              "xyz.example": ['alt.example', '*.alt.example']
            }
          }
        end

        it do
          is_expected.to contain_file("/tmp/all_cert_commands_cloudflare")
            .with_content(%r{certbot certonly --dns-cloudflare --dns-cloudflare-credentials ~/.secrets/certbot/cloudflare.ini -m "nope@nope.zone" -d "abc.example"})
        end

        it do
          is_expected.to contain_file("/tmp/all_cert_commands_cloudflare")
            .with_content(%r{certbot certonly --dns-cloudflare --dns-cloudflare-credentials ~/.secrets/certbot/cloudflare.ini -m "nope@nope.zone" -d "xyz.example,alt.example,\*.alt.example"})
        end

        it do
          is_expected.to contain_concat_fragment("/var/local/cert_dir/abc.example.crt cert")
            .with_target("/var/local/cert_dir/abc.example.crt")
            .with_source("/etc/letsencrypt/live/abc.example/fullchain.pem")
        end

        it do
          is_expected.to contain_concat_fragment("/var/local/cert_dir/xyz.example.crt cert")
            .with_target("/var/local/cert_dir/xyz.example.crt")
            .with_source("/etc/letsencrypt/live/xyz.example/fullchain.pem")
        end
      end
    end
  end
end
