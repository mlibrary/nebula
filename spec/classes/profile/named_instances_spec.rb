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
          path: '/my/app/path/myapp-testing',
          uid: 20_001,
          gid: 30_001,
          users: %w[alice bob],
          subservices: ['resque-pool', 'mailman'],
        }
      end
      let(:hydra_staging) do
        {
          name: 'hydra-staging',
          path: '/hydra-dev/hydra-staging',
          uid: 20_002,
          gid: 30_002,
          users: %w[solr bill],
          subservices: [],
        }
      end

      context 'with instances' do
        let(:params) { { instances: [myapp_testing, hydra_staging] } }

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
          is_expected.to contain_nebula__named_instance(hydra_staging[:name]).with(path: hydra_staging[:path],
                                                                                   uid: hydra_staging[:uid],
                                                                                   gid: hydra_staging[:gid],
                                                                                   pubkey: 'somepublickey',
                                                                                   puma_config: 'config/fauxpaas_puma.rb',
                                                                                   users: hydra_staging[:users],
                                                                                   subservices: hydra_staging[:subservices])
        end
      end

      context 'without instances' do
        let(:params) { {} }

        it { is_expected.to compile }
      end
    end
  end
end
