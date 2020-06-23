# frozen_string_literal: true

# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'
describe 'nebula::profile::www_lib::cron' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      context 'with user set to "cron_friend"' do
        let(:params) { { user: 'cron_friend' } }

        it { is_expected.to contain_cron('purge cosign tickets').with_user('root') }
        it { is_expected.to contain_cron('staff.lib parse').with_user('cron_friend') }
      end

      context 'with mailto set to "crons@umich.edu"' do
        let(:params) { { mailto: 'crons@umich.edu' } }

        it { is_expected.to contain_cron('purge cosign tickets').without_environment }
        it { is_expected.to contain_cron('staff.lib parse').with_environment(['MAILTO=crons@umich.edu']) }
      end

      context 'with an additional cronjob to echo "hello" at 1:23 daily' do
        let(:params) { { extra_jobs: extra_jobs } }
        let(:extra_jobs) do
          {
            'my_title'  => {
              'hour'    => 1,
              'minute'  => 23,
              'command' => 'echo hello',
            },
          }
        end

        it { is_expected.to contain_cron('my_title').with_hour(1) }
        it { is_expected.to contain_cron('my_title').with_minute(23) }
        it { is_expected.to contain_cron('my_title').with_command('echo hello') }
      end
    end
  end
end
