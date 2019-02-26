# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::named_instance::solr_params' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      xdescribe 'exported resources'

      describe 'concat_fragments' do
        let(:target) { "#{instance} deploy init" }

        context 'for first-instance' do
          let(:instance) { 'first-instance' }
          let(:title) { "somecore" }
          let(:params) do
            {
              instance: instance,
              path: '/nonexistent',
              index: 1,
              solr_params: {
                'host' => 'localhost',
                'port' => 8082
              }
            }
          end

          it do
            is_expected.to contain_concat_fragment("first-instance deploy init infrastructure.solr.1").with(
              target: target,
              content: '{"infrastructure":{"solr":{"1":"http://localhost:8082/foo/bar"}}}'
            )
          end
        end

        xcontext 'for second-instance' do
          let(:instance) { 'second-instance' }
          let(:title) { 'anothercore' }
          let(:params) do
            {
              instance: instance,
              index: 99,
              url: 'http://somehost.default.invalid:12345/solr/whatever',
            }
          end

          {
            'infrastructure.solr.99' => '{"infrastructure":{"solr":{"99":"http://somehost.default.invalid:12345/solr/whatever"}}}',
          }
            .each do |fragment_title, content|
            describe fragment_title do
              it "sets #{content}" do
                is_expected.to contain_concat_fragment("#{instance} deploy init #{fragment_title}").with(
                  target: target,
                  content: content,
                )
              end
            end
          end
        end
      end
    end
  end
end
