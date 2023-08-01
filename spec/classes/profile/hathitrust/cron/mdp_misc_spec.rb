
# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::hathitrust::cron::mdp_misc' do
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
          is_expected.to contain_cron('manage mbook sessions')
            .with(command: %r{/htapps/babel/mdp-misc/scripts/managembookssessions\.pl.*mail.*nobody@default\.invalid},

                  user: 'libadm',
                  environment: [
                    'SDRROOT=/htapps/babel',
                    'SDRDATAROOT=/sdr1',
                    'HOME=/htapps/babel/mdp-misc',
                    "MAILTO=''",
                  ],
                  minute: 5)
        end
      end

      context 'with all params' do
        let(:params) do
          {
            mail_recipient: 'somebody@default.invalid',
            user: 'cronuser',
            sdr_root: '/somewhere',
            sdr_data_root: '/elsewhere',
            home: '/homewhere',
            mdp_sessions_minute: 30,
          }
        end

        it do
          is_expected.to contain_cron('manage mbook sessions')
            .with(command: %r{.*/homewhere/scripts/managembookssessions\.pl.*mail.*somebody@default\.invalid},
                  user: 'cronuser',
                  environment: [
                    'SDRROOT=/somewhere',
                    'SDRDATAROOT=/elsewhere',
                    'HOME=/homewhere',
                    "MAILTO=''",
                  ],
                  minute: 30)
        end
      end
    end
  end
end
