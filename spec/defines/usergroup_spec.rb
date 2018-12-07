# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::usergroup' do
  let(:title) { 'examplegroup1' }
  let(:params) do
    {}
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:hiera_config) { 'spec/fixtures/hiera/usergroups_config.yaml' }
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_group('examplegroup1') }

      it { is_expected.to contain_user('exampleuser1') }
      it { is_expected.to contain_user('exampleuser2') }
      it { is_expected.not_to contain_user('exampleuser3') }

      # Rubocop made me put this underscore here.
      it { is_expected.to contain_user('exampleuser1').with_uid(12_345) }
      it { is_expected.to contain_user('exampleuser1').with_comment('The first example user') }
      it { is_expected.to contain_user('exampleuser1').with_home('/home/exampleuser1') }
      it { is_expected.to contain_user('exampleuser1').with_gid('staff') }
      it { is_expected.to contain_user('exampleuser1').with_groups(%w[examplegroup1]) }

      it { is_expected.to contain_user('exampleuser2').with_uid(12_346) }
      it { is_expected.to contain_user('exampleuser2').with_comment('The second example user') }
      it { is_expected.to contain_user('exampleuser2').with_home('/home/exampleuser2') }
      it { is_expected.to contain_user('exampleuser2').with_gid('staff') }
      it { is_expected.to contain_user('exampleuser2').with_groups(%w[examplegroup1 examplegroup2]) }

      context 'when creating examplegroup2' do
        let(:title) { 'examplegroup2' }

        it { is_expected.to compile }
        it { is_expected.to contain_group('examplegroup2') }

        it { is_expected.not_to contain_user('exampleuser1') }
        it { is_expected.to contain_user('exampleuser2') }
        it { is_expected.to contain_user('exampleuser3') }
      end
    end
  end
end
