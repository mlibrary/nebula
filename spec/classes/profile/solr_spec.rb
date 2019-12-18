# frozen_string_literal: true

# Copyright (c) 2018-2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::solr' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      context 'with package' do
        [
          'openjdk-8-jre-headless',
          'solr',
          'lsof',
        ].each do |package|
          it { is_expected.to contain_package(package) }
        end
      end

      context 'with directory' do
        [
          '/var/lib/solr',
          '/var/lib/solr/home',
          '/var/lib/solr/logs',
        ].each do |path|
          it do
            is_expected.to contain_file(path).with(
              owner: 'solr',
              group: 'solr',
              ensure: 'directory',
              mode: '0750',
            )
          end
        end
      end

      context 'with config file' do
        [
          '/var/lib/solr',
          '/var/lib/solr/home',
          '/var/lib/solr/logs',
        ].each do |path|
          it do
            is_expected.to contain_file(path).with(
              owner: 'solr',
              group: 'solr',
              ensure: 'directory',
              mode: '0750',
            )
          end
        end
      end

      context 'with solr service' do
        it do
          is_expected.to contain_service('solr').with(
            enable: true,
            ensure: 'running',
          )
        end
      end
    end
  end
end
