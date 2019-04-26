# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::tools_lib::postgres' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:hiera_config) { 'spec/fixtures/hiera/tools_lib_config.yaml' }

      it { is_expected.to contain_postgresql__server__db('jira') }
      it { is_expected.to contain_postgresql__server__db('confluence') }

      it { is_expected.to contain_file('/var/local/pgbackup/backup') }
      it { is_expected.to contain_cron('backup postgres databases').with_command(%r{.*backup.*}) }

      context 'with configured s3 backup destination' do
        let(:params) { { s3_backup_dest: 's3://somewhere/whatever' } }

        it do
          is_expected.to contain_cron('backup postgres confluence dump to s3')
            .with_command(%r{aws s3 cp .* /var/local/pgbackup/confluence.dump s3://somewhere/whatever})
        end

        it do
          is_expected.to contain_cron('backup postgres jira dump to s3')
            .with_command(%r{aws s3 cp .* /var/local/pgbackup/jira.dump s3://somewhere/whatever})
        end
      end
    end
  end
end
