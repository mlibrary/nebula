# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'
require 'faker'

describe 'nebula::role::hathitrust::ingest_indexing::primary' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:hiera_config) { 'spec/fixtures/hiera/hathitrust_config.yaml' }

      it { is_expected.to compile }

      it do
        is_expected.to contain_cron('mail rights load summary')
          .with_command('/usr/bin/mail -s "Rights load summary" nobody@default.invalid < /tmp/populate_rights.log; mv /tmp/populate_rights.log /htfeed/var/log/populate_rights_`date +"\%Y\%m\%d"`.log')
      end

      it do
        is_expected.to contain_cron('daily tasks').with_environment(
          [
            'MAILTO=nobody@default.invalid',
            'FEED_HOME=/htfeed',
            'HTFEED_CONFIG=/default/feedd.yaml',
          ],
        )
      end
    end
  end
end
