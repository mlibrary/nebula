# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::named_instance::solr_params' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:target) { "#{instance} deploy init" }

      context 'for first-instance' do
        let(:instance) { 'first-instance' }
        let(:title) { 'somecore' }
        let(:path) { '/nonexistent' }
        let(:params) do
          {
            instance: instance,
            path: path,
            solr_params: {
              'host' => 'localhost',
              'port' => 8082,
              'index' => 1,
            },
          }
        end

        it do
          is_expected.to contain_concat_fragment("#{instance} deploy init infrastructure.solr.1").with(
            target: target,
            content: '{"infrastructure":{"solr":{"1":"http://localhost:8082/solr/somecore"}}}',
          )
        end

        it do
          expect(exported_resources).to contain_nebula__named_instance__solr_core('somecore').with(
            instance: instance,
            instance_path: path,
          )
        end
      end

      context 'for second-instance' do
        let(:instance) { 'second-instance' }
        let(:title) { 'anothercore' }
        let(:path) { '/somewhere' }
        let(:params) do
          {
            instance: instance,
            path: path,
            solr_params: {
              'host' => 'somehost.default.invalid',
              'port' => 12_345,
              'index' => 99,
            },
          }
        end

        it do
          is_expected.to contain_concat_fragment("#{instance} deploy init infrastructure.solr.99").with(
            target: target,
            content: '{"infrastructure":{"solr":{"99":"http://somehost.default.invalid:12345/solr/anothercore"}}}',
          )
        end

        it do
          expect(exported_resources).to contain_nebula__named_instance__solr_core('anothercore').with(
            instance: instance,
            instance_path: path,
          )
        end
      end
    end
  end
end
