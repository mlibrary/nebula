# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::base::users' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to contain_group('invalid_default_group').with_gid(1234) }
      it { is_expected.to contain_group('invalid_special_group').with_gid(2468) }

      it do
        is_expected.to contain_user('invalid_normal_admin').with(
          comment: 'Invalid normal admin',
          gid: 'invalid_default_group',
          uid: 123_456,
          home: '/home/invalid_normal_admin',
          managehome: false,
          shell: '/bin/bash',
          groups: ['sudo'],
        )
      end

      it do
        is_expected.to contain_user('invalid_special_admin').with(
          comment: 'Invalid special admin',
          gid: 'invalid_special_group',
          uid: 123_457,
          home: '/home/invalid_special_admin',
          managehome: false,
          shell: '/bin/bash',
          groups: ['sudo'],
        )
      end

      it do
        is_expected.to contain_user('invalid_noauth_admin').with(
          comment: 'Invalid no-authorization admin',
          gid: 'invalid_default_group',
          uid: 123_458,
          home: '/home/invalid_noauth_admin',
          managehome: false,
          shell: '/bin/bash',
          groups: ['sudo'],
        )
      end
    end
  end
end
