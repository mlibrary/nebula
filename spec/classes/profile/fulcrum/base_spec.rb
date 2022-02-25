# frozen_string_literal: true

# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::fulcrum::base' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      context "with default uid and gid" do
        it do
          is_expected.to contain_user('fulcrum')
            .with(uid: 717)
            .with(gid: 717)
        end

        it do
          is_expected.to contain_group('fulcrum')
            .with(gid: 717)
        end
      end

      context "with a uid and gid specified" do
        let(:params) {
          {
            uid: 1001,
            gid: 1001
          }
        }

        it do
          is_expected.to contain_user('fulcrum')
            .with(uid: 1001)
            .with(gid: 1001)
        end

        it do
          is_expected.to contain_group('fulcrum')
            .with(gid: 1001)
        end
      end
    end
  end
end
