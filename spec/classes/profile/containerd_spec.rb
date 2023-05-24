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
    end
  end
end
