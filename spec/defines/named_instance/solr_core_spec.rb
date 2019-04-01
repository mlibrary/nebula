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
            host: 'localhost',
            port: 8081,
            instance_path: '/nonexistent/myapp-testing',
            solr_home: '/var/lib/solr-whatever/home',
            instance: 'myapp-testing',
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
          is_expected.to contain_file('/var/lib/solr-whatever/home/mycore')
            .with(ensure: 'link', target: '/nonexistent/solr_home/mycore')
        end

        it do
          is_expected.to contain_exec('initialize solr core mycore').with(
            unless: '/usr/bin/wget -O - --quiet http://localhost:8081/solr/mycore/admin/ping > /dev/null',
            command: '/usr/bin/wget -O - --quiet "http://localhost:8081/solr/admin/cores?action=CREATE&name=mycore&' \
                     'instanceDir=/var/lib/solr-whatever/home/mycore&config=solrconfig.xml&dataDir=data" > /dev/null',
          )
        end
      end

      context 'overriding all params' do
        let(:title) { 'anothercore' }
        let(:params) do
          {
            instance_path: '/somewhere/something-testing',
            instance: 'something-testing',
            solr_home: '/var/lib/solr-another/home',
            core_home: '/somewhere/solr_cores',
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
            .with(ensure: 'directory', owner: 'solruser')
        end

        it do
          is_expected.to contain_file('/somewhere/solr_cores/anothercore/conf')
            .with(ensure: 'link', target: '/somewhere/something-testing/current/solr/anothercore-conf')
        end

        it do
          is_expected.to contain_exec('initialize solr core anothercore').with(
            unless: '/usr/bin/wget -O - --quiet http://solrhost:12345/solr/anothercore/admin/ping > /dev/null',
            command: '/usr/bin/wget -O - --quiet "http://solrhost:12345/solr/admin/cores?action=CREATE&name=anothercore&' \
                     'instanceDir=/var/lib/solr-another/home/anothercore&config=solrconfig.xml&dataDir=data" > /dev/null',
          )
        end
      end
    end
  end
end
