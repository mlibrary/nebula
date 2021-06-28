# frozen_string_literal: true

# Copyright (c) 2019-2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::kubernetes::filesystems' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:hiera_config) { 'spec/fixtures/hiera/kubernetes/default_config.yaml' }
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_package('nfs-common') }

      context 'when a cifs_mount is defined' do
        let(:params) do
          {
            cifs_mounts: {
              'bad_thing'       => {
                'remote_target' => '//kubernetes.default.invalid/kubernetes',
                'uid'           => 'default',
                'gid'           => 'default',
                'user'          => 'kubernetes',
              },
            },
          }
        end

        it { is_expected.to contain_nebula__cifs_mount('/mnt/legacy_cifs_bad_thing') }
      end
    end
  end
end
