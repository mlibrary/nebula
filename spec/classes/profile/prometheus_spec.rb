# frozen_string_literal: true

# Copyright (c) 2025 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require "spec_helper"

describe "nebula::profile::prometheus" do
  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_package("prometheus") }
      it { is_expected.to contain_service("prometheus") }
      it { is_expected.to contain_package("prometheus-pushgateway") }
      it { is_expected.to contain_service("prometheus-pushgateway") }

      it do
        is_expected.to contain_exec("divert /etc/prometheus/prometheus.yml")
          .with_command("/usr/bin/dpkg-divert --rename --divert /etc/prometheus/prometheus.yml.dist --add /etc/prometheus/prometheus.yml")
          .with_creates("/etc/prometheus/prometheus.yml.dist")
          .that_requires("Package[prometheus]")
      end

      it do
        is_expected.to contain_exec("divert /etc/default/prometheus-pushgateway")
          .with_command("/usr/bin/dpkg-divert --rename --divert /etc/default/prometheus-pushgateway.dist --add /etc/default/prometheus-pushgateway")
          .with_creates("/etc/default/prometheus-pushgateway.dist")
          .that_requires("Package[prometheus-pushgateway]")
      end

      it do
        is_expected.to contain_file("/etc/prometheus/prometheus.yml")
          .that_notifies("Service[prometheus]")
          .that_requires("Exec[divert /etc/prometheus/prometheus.yml]")
      end

      it do
        is_expected.to contain_file("/var/lib/prometheus/pushgateway")
          .with_ensure("directory")
          .with_owner("prometheus")
          .with_group("prometheus")
      end

      it do
        is_expected.to contain_file("/etc/default/prometheus-pushgateway")
          .with_content("ARGS=\"--persistence.file=/var/lib/prometheus/pushgateway/archive\"\n")
          .that_notifies("Service[prometheus-pushgateway]")
          .that_requires("Exec[divert /etc/default/prometheus-pushgateway]")
          .that_requires("File[/var/lib/prometheus/pushgateway]")
      end
    end
  end
end
