
# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::hathitrust::cron::statistics' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with default params' do
        let(:params) do
          {
            mail_recipient: 'nobody@default.invalid',
          }
        end

        it do
          is_expected.to contain_cron('callnumber prefix counts')
            .with(command: %r{.*perl /htapps/www/sites/www\.hathitrust\.org/modules/custom/callnumber_prefix_counts\.pl.*mail.*nobody@default\.invalid},
                  user: 'libadm',
                  environment: ['MAILTO=nobody@default.invalid', 'SDRROOT=/htapps/www'])
        end
      end

      context 'with all params' do
        let(:params) do
          {
            mail_recipient: 'somebody@default.invalid',
            user: 'cronuser',
            sdr_root: '/nowhere',

          }
        end

        it do
          is_expected.to contain_cron('callnumber prefix counts')
            .with(command: %r{.*perl /nowhere/sites/www\.hathitrust\.org/modules/custom/callnumber_prefix_counts\.pl.*mail.*somebody@default\.invalid},
                  user: 'cronuser',
                  environment: ['MAILTO=somebody@default.invalid', 'SDRROOT=/nowhere'])
        end
      end
    end
  end
end
