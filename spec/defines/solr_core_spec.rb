# frozen_string_literal: true

# Copyright (c) 2018-2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::named_instance::solr_core' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts.merge(hostname: 'thishost') }

      context 'with required/default params' do
        let(:title) { 'mycore' }
        let(:params) do
          {
            instance_path: '/nonexistent/myapp-testing',
            instance_title: 'myapp-testing',
            index: 1,
          }
        end

        it do
          is_expected.to contain_file('/nonexistent/myapp-testing/releases/0/solr')
            .with_owner('myapp-testing')
        end

        it do
          is_expected.to contain_file('/nonexistent/myapp-testing/releases/0/solr/conf')
            .with(ensure: 'link',
                  # from hiera
                  target: '/nonexistent/solr/conf')
        end

        it do
          is_expected.to contain_file('/nonexistent/solr_home/mycore')
            .with(ensure: 'directory', owner: 'solr')
        end

        it do
          is_expected.to contain_file('/nonexistent/myapp-testing/current')
            .with(ensure: 'link', target: '/nonexistent/myapp-testing/releases/0', replace: 'false')
        end

        it do
          is_expected.to contain_file('/nonexistent/solr_home/mycore/conf')
            .with(ensure: 'link', target: '/nonexistent/myapp-testing/current/solr/conf')
        end

        it do
          is_expected.to contain_exec('initialize solr core mycore').with(
            unless: '/usr/bin/wget -O - --quiet http://localhost:8081/solr/mycore/admin/ping > /dev/null',
            command: '/usr/bin/wget -O - --quiet "http://localhost:8081/solr/admin/cores?action=CREATE&name=mycore&' \
                     'instanceDir=/nonexistent/solr_home/mycore&config=solrconfig.xml&dataDir=data" > /dev/null',
          )
        end

        it 'exports solr core params for moku' do
          expect(exported_resources).to contain_nebula__named_instance__moku_solr_params('myapp-testing mycore thishost').with(
            instance: 'myapp-testing',
            url: 'http://localhost:8081/solr/mycore',
            index: 1,
          )
        end
      end

      context 'overriding all params' do
        let(:title) { 'anothercore' }
        let(:params) do
          {
            instance_path: '/somewhere/something-testing',
            instance_title: 'something-testing',
            solr_home: '/somewhere/solr_cores',
            config_dir: 'anothercore-conf',
            host: 'solrhost',
            port: 12_345,
            default_config: '/somewhere/default-config',
            solr_user: 'solruser',
            solr_group: 'solrgroup',
            index: 99,
          }
        end

        it do
          is_expected.to contain_file('/somewhere/something-testing/releases/0/solr/anothercore-conf')
            .with(ensure: 'link',
                  # from hiera
                  target: '/somewhere/default-config')
        end

        it do
          is_expected.to contain_file('/somewhere/solr_cores/anothercore')
            .with(ensure: 'directory', owner: 'solr')
        end

        it do
          is_expected.to contain_file('/somewhere/solr_cores/anothercore/conf')
            .with(ensure: 'link', target: '/somewhere/something-testing/current/solr/anothercore-conf')
        end

        it do
          is_expected.to contain_exec('initialize solr core anothercore').with(
            unless: '/usr/bin/wget -O - --quiet http://solrhost:12345/solr/anothercore/admin/ping > /dev/null',
            command: '/usr/bin/wget -O - --quiet "http://solrhost:12345/solr/admin/cores?action=CREATE&name=anothercore&' \
                     'instanceDir=/somewhere/solr_cores/anothercore&config=solrconfig.xml&dataDir=data" > /dev/null',
          )
        end

        it 'exports solr core params for moku' do
          expect(exported_resources).to contain_nebula__named_instance__moku_solr_params('something-testing anothercore thishost').with(
            instance: 'something-testing',
            url: 'http://solrhost:12345/solr/anothercore',
            index: 99,
          )
        end
      end
    end
  end
end
