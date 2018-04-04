# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::puppet::master' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it do
        is_expected.to contain_class('puppetdb::master::config')
          .with_puppetdb_server('puppetdb.default.invalid')
      end

      context 'when given a puppetdb_server of db.puppet.gov' do
        let(:params) { { puppetdb_server: 'db.puppet.gov' } }

        it do
          is_expected.to contain_class('puppetdb::master::config')
            .with_puppetdb_server('db.puppet.gov')
        end
      end

      it do
        is_expected.to contain_rbenv__gem('r10k').with(
          ruby_version: '2.4.3',
          require: [
            'Class[Nebula::Profile::Ruby]',
            'Rbenv::Build[2.4.3]',
          ],
        )
      end

      it do
        is_expected.to contain_rbenv__gem('librarian-puppet').with(
          ruby_version: '2.4.3',
          require: [
            'Class[Nebula::Profile::Ruby]',
            'Rbenv::Build[2.4.3]',
          ],
        )
      end

      it do
        is_expected.to contain_tidy(
          '/opt/puppetlabs/server/data/puppetserver/reports',
        ).with(
          age: '1w',
          recurse: true,
        )
      end
    end
  end
end
