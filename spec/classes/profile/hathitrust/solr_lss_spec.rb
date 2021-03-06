# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::hathitrust::solr_lss' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:hiera_config) { 'spec/fixtures/hiera/hathitrust_config.yaml' }

      let(:params) do
        {
          port: 12_345,
          heap: '42G',
          coredata: {
            'mycore' => '/path/to/some/core/data',
            'othercore' => '/somewhere/another/core/data',
          },
        }
      end

      it { is_expected.to contain_group('solr') }
      it { is_expected.to contain_user('solr') }

      it { is_expected.to contain_file('/var/lib/solr').with(owner: 'solr', ensure: 'directory') }
      it { is_expected.to contain_file('/var/lib/solr/logs').with(owner: 'solr', ensure: 'directory') }
      it { is_expected.to contain_file('/var/lib/solr/home').with(owner: 'solr', ensure: 'directory') }

      it do
        is_expected.to contain_file('/var/lib/solr/log4j.properties').with_content(%r{solr.log})
      end

      it do
        is_expected.to contain_file('/var/lib/solr/home/solr.xml').with_content(%r{<str name="hostContext">/</str>})
      end

      [
        %r{SOLR_HOME="/var/lib/solr/home"},
        %r{SOLR_JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64/jre"},
        %r{SOLR_HEAP="42G"},
        %r{SOLR_PORT=12345},
        %r{SOLR_TIMEZONE="Somewhere/City"},
        %r{LOG4J_PROPS="/var/lib/solr/log4j.properties"},
        %r{SOLR_LOGS_DIR="/var/lib/solr/logs"},
        %r{SOLR_PID_DIR="/var/lib/solr/home"},
      ].each do |snippet|
        it { is_expected.to contain_file('/var/lib/solr/solr.in.sh').with_content(snippet) }
      end

      [
        %r{Environment="SOLR_INCLUDE=/var/lib/solr/solr.in.sh"},
        %r{ExecStart=/opt/solr/bin/solr start},
        %r{ExecStop=/opt/solr/bin/solr stop},
      ].each do |snippet|
        it { is_expected.to contain_file('/etc/systemd/system/solr.service').with_content(snippet) }
      end

      it do
        is_expected.to contain_file('/var/lib/solr/home/mycore/mycorex/data')
          .with(ensure: 'link', target: '/path/to/some/core/data')
      end

      it do
        is_expected.to contain_file('/var/lib/solr/home/mycore/mycorey/data')
          .with(ensure: 'link', target: '/path/to/some/core/data')
      end

      it do
        is_expected.to contain_file('/var/lib/solr/home/othercore/othercorex/data')
          .with(ensure: 'link', target: '/somewhere/another/core/data')
      end

      it do
        is_expected.to contain_file('/var/lib/solr/home/othercore/othercorey/data')
          .with(ensure: 'link', target: '/somewhere/another/core/data')
      end

      it do
        is_expected.to contain_file('/var/lib/solr/home/mycore/mycorex/core.properties')
          .with_content(<<~EOT)
            name=mycorex
          EOT
      end

      it do
        is_expected.to contain_file('/var/lib/solr/home/mycore/mycorey/core.properties')
          .with_content(<<~EOT)
            name=mycorey
            dataDir=/var/lib/solr/home/mycore/mycorex/data/
            loadOnStartup=false
          EOT
      end

      it do
        is_expected.to contain_file('/var/lib/solr/home/othercore/othercorex/core.properties')
          .with_content(<<~EOT)
            name=othercorex
          EOT
      end

      it do
        is_expected.to contain_file('/var/lib/solr/home/othercore/othercorey/core.properties')
          .with_content(<<~EOT)
            name=othercorey
            dataDir=/var/lib/solr/home/othercore/othercorex/data/
            loadOnStartup=false
          EOT
      end

      it { is_expected.to contain_file('/var/lib/solr/home/mycore/mycorex/lib') }
      it { is_expected.to contain_file('/var/lib/solr/home/mycore/mycorex/conf') }

      it do
        is_expected.to contain_file('/var/lib/solr/home/mycore/mycorex/conf/schema.xml')
          .with_source(%r{schema_x\.xml})
      end

      it { is_expected.to contain_file('/var/lib/solr/home/mycore/mycorey/lib') }
      it { is_expected.to contain_file('/var/lib/solr/home/mycore/mycorey/conf') }
      it { is_expected.to contain_file('/var/lib/solr/home/mycore/mycorey/conf/schema.xml') }

      it do
        is_expected.to contain_file('/var/lib/solr/home/mycore/mycorey/conf/schema.xml')
          .with_source(%r{schema_y\.xml})
      end
    end
  end
end
