# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::tools_lib::jira' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:hiera_config) { 'spec/fixtures/hiera/tools_lib_config.yaml' }
      let(:params) do
        {
          domain: 'something.whatever.edu',
          mail_recipient: 'nobody@default.invalid',
        }
      end

      it { is_expected.to contain_class('jira') }

      context 'with configured s3 backup destination' do
        let(:params) { super().merge(s3_backup_dest: 's3://somewhere/whatever') }

        it do
          is_expected.to contain_cron('backup jira xml dump to s3')
            .with_command(%r{aws s3 cp .* /var/opt/jira/export/`date \+\\%Y\\%m\\%d`.zip s3://somewhere/whatever/jira.zip})
        end

        it do
          is_expected.to contain_cron('remove old jira backup')
            .with_command(%r{rm /var/opt/jira/export/`date \+\\%Y\\%m\\%d`.zip})
        end
      end
    end
  end
end
