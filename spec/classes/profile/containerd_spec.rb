# frozen_string_literal: true

# Copyright (c) 2023 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::containerd' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_apt__source('docker') }
      it { is_expected.to contain_package('containerd.io').that_requires('Apt::Source[docker]') }
      it { is_expected.to contain_service('containerd').that_requires('Package[containerd.io]') }
      it { is_expected.to contain_file('/etc/containerd/config.toml').with_content(/^disabled_plugins = \[\]$/) }
      it { is_expected.to contain_file('/etc/containerd/config.toml').with_content(/^\s*SystemdCgroup = true$/) }
      it { is_expected.to contain_file('/etc/containerd').with_ensure("directory") }
      it { is_expected.to contain_file('/etc/containerd').that_comes_before("File[/etc/containerd/config.toml]") }
    end
  end
end
