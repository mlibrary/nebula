# frozen_string_literal: true

# Copyright (c) 2023 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::cron_runner' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_nebula__usergroup('cron') }
      it { is_expected.not_to contain_cron('delete old backups') }

      context 'when given a "delete old backups" cronjob' do
        let(:params) {
          {
            crons: {
              'delete old backups' => {
                'command' => "/usr/bin/find /backups -mtime +60 -exec rm '{}' + > /dev/null 2>&1",
                'user' => 'foo',
                'minute' => 50,
                'hour' => 5,
                'environment' => ['MAILTO=default@invalid.example']
              }
            }
          }
        }

        it { is_expected.to compile }
        it { is_expected.to contain_cron('delete old backups') }
      end
    end
  end
end
