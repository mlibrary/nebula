# frozen_string_literal: true

# Copyright (c) 2018, 2020 The Regents of the University of Michigan.
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
          is_expected.to contain_rbenv__build(version)
        end

        %w[puma rspec].each do |gem|
          it do
            is_expected.to contain_rbenv__gem("#{gem} #{version}").with(
              gem: gem,
              ruby_version: version,
              require: "Rbenv::Build[#{version}]",
            )
          end
        end
      end

      it do
        is_expected.to contain_exec('rbenv uninstall 2.4.2')
          .with_command('rbenv uninstall -f 2.4.2')
          .with_environment(['RBENV_ROOT=/opt/rbenv'])
          .with_path('/opt/rbenv/shims:/opt/rbenv/bin:/usr/bin:/bin')
          .that_requires('Rbenv::Build[2.4.3]')
      end

      it { is_expected.not_to contain_exec('rbenv uninstall 2.5.0') }

      case os
      when 'debian-8-x86_64'
        it { is_expected.to contain_rbenv__build('2.3.4').with_global(false) }
      when 'debian-9-x86_64'
        it { is_expected.not_to contain_rbenv__build('2.3.4') }
      end

      it { is_expected.to contain_rbenv__build('2.4.3').with_global(true) }
      it { is_expected.to contain_rbenv__build('2.5.0').with_global(false) }

      it { is_expected.to contain_file('/etc/cron.daily/ruby-health-check') }

      context 'when given install_dir of /usr/local/rbenv' do
        let(:params) { { install_dir: '/usr/local/rbenv' } }

        it do
          is_expected.to contain_class('rbenv').with(
            install_dir: '/usr/local/rbenv',
          )
        end

        it { is_expected.to contain_rbenv__build('2.4.3').with_global(true) }
        it { is_expected.to contain_file('/etc/cron.daily/ruby-health-check') }
      end

      context 'when given supported_versions of [2.4.1]' do
        let(:params) { { supported_versions: ['2.4.1'] } }

        it { is_expected.to contain_rbenv__build('2.4.1') }
        it { is_expected.not_to contain_rbenv__build('2.3.4') }
        it { is_expected.not_to contain_rbenv__build('2.5.0') }
      end

      # AEIM-2776 - Confirm jruby-1.7 is blacklisted by default
      context 'when given supported_versions of [jruby-1.7.anything]' do
        let(:params) { { supported_versions: ['jruby-1.7.anything'] } }

        it { is_expected.not_to contain_rbenv__build('jruby-1.7.anything') }
      end

      # AEIM-2776 - Confirm jruby-9.0 is blacklisted by default
      context 'when given supported_versions of [jruby-9.0.anything]' do
        let(:params) { { supported_versions: ['jruby-9.0.anything'] } }

        it { is_expected.not_to contain_rbenv__build('jruby-9.0.anything') }
      end

      # AEIM-2776 - Confirm we can blacklist by param
      context 'when supporting and blacklisting ree-0.0' do
        let(:params) { { supported_versions: ['ree-0.0'], manage_blacklist: '^ree-0' } }

        it { is_expected.not_to contain_rbenv__build('ree-0.0') }
      end

      context 'when given global_version of 2.4.1' do
        let(:params) { { global_version: '2.4.1', bundler_version: '~>1.14' } }

        it do
          is_expected.to contain_rbenv__build('2.4.1').with(
            bundler_version: '~>1.14',
            global: true,
          )
        end
      end

      context 'when given gems ["pry", "json"]' do
        let(:params) do
          {
            gems: [
              { gem: 'pry', version: '>= 0' },
              { gem: 'json', version: '>= 0' },
            ],
          }
        end

        it { is_expected.to contain_rbenv__gem('pry 2.4.3') }
        it { is_expected.to contain_rbenv__gem('pry 2.5.0') }
        it { is_expected.to contain_rbenv__gem('json 2.4.3') }
        it { is_expected.to contain_rbenv__gem('json 2.5.0') }

        it { is_expected.not_to contain_rbenv__gem('puma 2.4.3') }
        it { is_expected.not_to contain_rbenv__gem('puma 2.5.0') }
        it { is_expected.not_to contain_rbenv__gem('rspec 2.4.3') }
        it { is_expected.not_to contain_rbenv__gem('rspec 2.5.0') }
      end
    end
  end
end
