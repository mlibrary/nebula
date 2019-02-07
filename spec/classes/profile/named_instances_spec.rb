# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::named_instances' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:myapp_testing) do
        {
          name: 'myapp-testing',
          public_hostname: 'myapp-testing.default.invalid',
          port: 456,
          path: '/my/app/path/myapp-testing',
          uid: 20_001,
          gid: 30_001,
          mysql_user: 'myapp-testing',
          mysql_password: '12345',
          users: %w[alice bob],
          subservices: ['resque-pool', 'mailman'],
        }
      end
      let(:hydra_staging) do
        {
          name: 'hydra-staging',
          public_hostname: 'myapp-testing.default.invalid',
          port: 123,
          path: '/hydra-dev/hydra-staging',
          uid: 20_002,
          gid: 30_002,
          mysql_user: 'myapp-testing',
          mysql_password: '12345',
          users: %w[solr bill],
          subservices: [],
        }
      end

      context 'with instances' do
        let(:params) do
          {
            instances: {
              'myapp-testing' => myapp_testing,
              'hydra-staging' => hydra_staging,
            },
          }
        end

        describe 'puma wrapper' do
          let(:klass) { 'nebula::profile::named_instances::puma_wrapper' }

          it { is_expected.to contain_class(klass).with(path: '/l/local/bin/profile_puma_wrap') }
          it { is_expected.to contain_class(klass).with(rbenv_root: '/opt/rbenv') }
          it { is_expected.to contain_class(klass).with(puma_config: 'config/fauxpaas_puma.rb') }
        end

        it do
          is_expected.to contain_nebula__named_instance(myapp_testing[:name]).with(
            path: myapp_testing[:path],
            uid: myapp_testing[:uid],
            gid: myapp_testing[:gid],
            pubkey: 'somepublickey',
            puma_config: 'config/fauxpaas_puma.rb',
            users: myapp_testing[:users],
            subservices: myapp_testing[:subservices],
          )
        end

        it do
          is_expected.to contain_nebula__named_instance(hydra_staging[:name]).with(
            path: hydra_staging[:path],
            uid: hydra_staging[:uid],
            gid: hydra_staging[:gid],
            pubkey: 'somepublickey',
            puma_config: 'config/fauxpaas_puma.rb',
            users: hydra_staging[:users],
            subservices: hydra_staging[:subservices],
          )
        end

        describe 'databases' do
          context 'when create_databases is false' do
            let(:params) { super().merge(create_databases: false) }

            it { is_expected.to have_mysql__db_count(0) }
          end

          it { is_expected.to contain_mysql__db('myapp-testing') }
          it { is_expected.to contain_mysql__db('hydra-staging') }
        end
      end

      context 'without instances' do
        let(:params) { {} }

        it { is_expected.to compile }
      end
    end
  end
end
