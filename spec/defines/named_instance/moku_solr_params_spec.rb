# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::named_instance::moku_solr_params' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      describe 'concat_fragments' do
        let(:target) { "#{name} deploy init" }
        let(:title) { "#{name} thishost" }

        context 'for first-instance' do
          let(:name) { 'first-instance' }
          let(:params) do
            {
              instance: name,
              index: 1,
              url: 'http://localhost:8082/foo/bar',
            }
          end

          {
            'infrastructure.solr.1' => '{"infrastructure":{"solr":{"1":"http://localhost:8082/foo/bar"}}}',
          }
            .each do |fragment_title, content|
            describe fragment_title do
              it "sets #{content}" do
                is_expected.to contain_concat_fragment("#{name} deploy init #{fragment_title}").with(
                  target: target,
                  content: content,
                )
              end
            end
          end
        end

        context 'for second-instance' do
          let(:name) { 'second-instance' }
          let(:params) do
            {
              instance: name,
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
                is_expected.to contain_concat_fragment("#{name} deploy init #{fragment_title}").with(
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
