# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require "spec_helper"

describe "nebula::profile::ezproxy::ssl_key" do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      # Test default parameters
      context "with default parameters" do
        it { is_expected.to compile.with_all_deps }

        # Check directory resource
        it {
          is_expected.to contain_file("/l/local/ezproxy/var/ssl").with(
            "ensure" => "directory",
            "owner" => "ezproxy",
            "group" => "ezproxy",
            "mode" => "0700"
          )
        }

        # Check certificate copy
        it {
          is_expected.to contain_file("/etc/ssl/certs/proxy.lib.umich.edu.crt").with(
            "mode" => "0640",
            "owner" => "nobody",
            "group" => "ezproxy",
            "source" => "puppet:///ssl-certs/proxy.lib.umich.edu.crt"
          )
        }

        # Check chain copy
        it {
          is_expected.to contain_file("/etc/ssl/certs/chain.pem").with(
            "mode" => "0640",
            "owner" => "nobody",
            "group" => "ezproxy",
            "source" => "puppet:///ssl-certs/chain.crt"
          )
        }

        # Check key copy
        it {
          is_expected.to contain_file("/etc/ssl/private/proxy.lib.umich.edu.key").with(
            "mode" => "0640",
            "owner" => "nobody",
            "group" => "ezproxy",
            "source" => "puppet:///ssl-certs/proxy.lib.umich.edu.key"
          )
        }

        # Check symlinks (cert_id = 11 formatted as %08d -> 00000011)
        it {
          is_expected.to contain_file("/l/local/ezproxy/var/ssl/00000011.crt").with(
            "ensure" => "link",
            "target" => "/etc/ssl/certs/proxy.lib.umich.edu.crt"
          )
            .that_requires("File[/l/local/ezproxy/var/ssl]")
            .that_notifies("Service[ezproxy]")
        }

        it {
          is_expected.to contain_file("/l/local/ezproxy/var/ssl/00000011.key").with(
            "ensure" => "link",
            "target" => "/etc/ssl/private/proxy.lib.umich.edu.key"
          )
            .that_requires("File[/l/local/ezproxy/var/ssl]")
            .that_notifies("Service[ezproxy]")
        }

        it {
          is_expected.to contain_file("/l/local/ezproxy/var/ssl/00000011.ca").with(
            "ensure" => "link",
            "target" => "/etc/ssl/certs/chain.pem"
          )
            .that_requires("File[/l/local/ezproxy/var/ssl]")
            .that_notifies("Service[ezproxy]")
        }

        # Check active file
        it {
          is_expected.to contain_file("/l/local/ezproxy/var/ssl/active").with(
            "ensure" => "file",
            "owner" => "ezproxy",
            "group" => "ezproxy",
            "mode" => "0644",
            "content" => "11\n"
          )
            .that_requires("File[/l/local/ezproxy/var/ssl]")
            .that_notifies("Service[ezproxy]")
        }

        # Check service
        it {
          is_expected.to contain_service("ezproxy").with(
            "ensure" => "running",
            "enable" => true
          )
        }
      end
    end
  end
end
