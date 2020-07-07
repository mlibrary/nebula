# frozen_string_literal: true

# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::kubernetes::bootstrap::user' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it do
        is_expected.to contain_user('kubeadm_bootstrap')
          .with_home('/var/lib/kubeadm_bootstrap')
      end

      it do
        is_expected.to contain_file('/var/lib/kubeadm_bootstrap')
          .with_ensure('directory')
          .with_owner('kubeadm_bootstrap')
          .that_requires('User[kubeadm_bootstrap]')
      end

      it do
        is_expected.to contain_file('/var/lib/kubeadm_bootstrap/.ssh')
          .with_ensure('directory')
          .with_owner('kubeadm_bootstrap')
          .with_mode('0700')
          .that_requires('File[/var/lib/kubeadm_bootstrap]')
      end
    end
  end
end
