# frozen_string_literal: true

# Copyright (c) 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::known_host_public_keys' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with fqdn of example.invalid and some ssh public keys' do
        let(:facts) do
          {
            'fqdn' => "example.invalid",
            "ssh" => {
              "ecdsa" => {
                "type" => "ecdsa-sha2-nistp256",
                "key" => "ecdsa_key"
              },
              "rsa" => {
                "type" => "ssh-rsa",
                "key" => "rsa_key"
              }
            }
          }
        end

        it { is_expected.to compile }

        it "exports an ssh_known_hosts line for its ecdsa key" do
          expect(exported_resources).to contain_concat_fragment("known host example.invalid ecdsa")
            .with_target("/etc/ssh/ssh_known_hosts")
            .with_tag("known_host_public_keys")
            .with_content("example.invalid ecdsa-sha2-nistp256 ecdsa_key\n")
        end

        it "exports an ssh_known_hosts line for its rsa key" do
          expect(exported_resources).to contain_concat_fragment("known host example.invalid rsa")
            .with_target("/etc/ssh/ssh_known_hosts")
            .with_tag("known_host_public_keys")
            .with_content("example.invalid ssh-rsa rsa_key\n")
        end
      end
    end
  end
end
