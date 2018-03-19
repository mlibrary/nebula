# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::ruby' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it do
        is_expected.to contain_class('rbenv').with(
          install_dir: '/opt/rbenv',
        )
      end

      [
        'rbenv/rbenv-vars',
        'rbenv/ruby-build',
        'rbenv/rbenv-default-gems',
        'tpope/rbenv-aliases',
      ].each do |plugin|
        it { is_expected.to contain_rbenv__plugin(plugin) }
      end

      ['2.4.3', '2.5.0'].each do |version|
        it do
          is_expected.to contain_rbenv__build(version).with(
            bundler_version: '~>1.14',
          )
        end
      end

      case os
      when 'debian-8-x86_64'
        it { is_expected.to contain_rbenv__build('2.3.4') }
      when 'debian-9-x86_64'
        it { is_expected.not_to contain_rbenv__build('2.3.4') }
      end

      it do
        is_expected.to contain_exec('rbenv-global').with(
          command: '/opt/rbenv/bin/rbenv global 2.4.3',
          require: 'Rbenv::Build[2.4.3]',
        )
      end

      context 'when given install_dir of /usr/local/rbenv' do
        let(:params) { { install_dir: '/usr/local/rbenv' } }

        it do
          is_expected.to contain_class('rbenv').with(
            install_dir: '/usr/local/rbenv',
          )
        end

        it do
          is_expected.to contain_exec('rbenv-global').with(
            command: '/usr/local/rbenv/bin/rbenv global 2.4.3',
            require: 'Rbenv::Build[2.4.3]',
          )
        end
      end

      context 'when given supported_versions of [2.4.1]' do
        let(:params) { { supported_versions: ['2.4.1'] } }

        it { is_expected.to contain_rbenv__build('2.4.1') }
        it { is_expected.not_to contain_rbenv__build('2.3.4') }
        it { is_expected.not_to contain_rbenv__build('2.5.0') }
      end

      context 'when given global_version of 2.4.1' do
        let(:params) { { global_version: '2.4.1' } }

        it do
          is_expected.to contain_rbenv__build('2.4.1').with(
            bundler_version: '~>1.14',
          )
        end

        it do
          is_expected.to contain_exec('rbenv-global').with(
            command: '/opt/rbenv/bin/rbenv global 2.4.1',
            require: 'Rbenv::Build[2.4.1]',
          )
        end
      end
    end
  end
end
