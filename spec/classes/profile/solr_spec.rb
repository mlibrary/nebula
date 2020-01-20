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

      # Packages
      [
        'openjdk-8-jre-headless',
        'solr',
        'lsof',
      ].each do |package|
        it { is_expected.to contain_package(package) }
      end

      # Service
      it do
        is_expected.to contain_service('solr').with(
          enable: true,
          ensure: 'running',
        )
      end

      context 'with default parameters' do
        # Directories
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

        # Files
        [
          '/var/lib/solr/log4j.properties',
          '/var/lib/solr/solr.in.sh',
          '/var/lib/solr/home/solr.xml',
        ].each do |path|
          it do
            is_expected.to contain_file(path).with(
              owner: 'solr',
              group: 'solr',
              ensure: 'file',
              mode: '0644',
            )
          end
        end
      end
    end
  end
end
