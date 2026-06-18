# frozen_string_literal: true

# Copyright (c) 2026 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require "spec_helper"
describe "nebula::profile::quod::prod::apache2" do
  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_service("apache2") }

      it do
        is_expected.to contain_file("/etc/apache2")
          .with_source("puppet:///quod-apache/apache2")
          .with_ensure("directory")
          .with_mode("u+rwX,go+rX,go-w")
          .with_owner("root")
          .with_group("root")
          .with_recurse(true)
          .with_purge(false)
          .with_links("manage")
          .that_notifies("Service[apache2]")
      end

      it do
        is_expected.to contain_file("/etc/apache2/mods-available/auth_openidc.conf")
          .with_source("puppet:///quod-apache/apache2/mods-available/auth_openidc.conf")
          .with_mode("0600")
          .with_owner("root")
          .with_group("root")
          .that_notifies("Service[apache2]")
      end

      it do
        is_expected.to contain_file("/etc/logrotate.d/apache2")
          .with_source("puppet:///quod-apache/logrotate.d/apache2")
          .with_mode("0644")
          .with_owner("root")
          .with_group("root")
      end
    end
  end
end
