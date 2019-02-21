
# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::hathitrust::cron::catalog' do
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
          is_expected.to contain_cron('clean sessions')
            .with(command: %r{.*perl /htapps/catalog/web/derived_data/clean_sessions\.pl},
                  user: 'libadm',
                  environment: ['MAILTO=nobody@default.invalid'])
        end
      end

      context 'with all params' do
        let(:params) do
          {
            mail_recipient: 'somebody@default.invalid',
            user: 'cronuser',
            catalog_home: '/nowhere',
          }
        end

        it do
          is_expected.to contain_cron('clean sessions')
            .with(command: %r{.*perl /nowhere/derived_data/clean_sessions\.pl},
                  user: 'cronuser',
                  environment: ['MAILTO=somebody@default.invalid'])
        end
      end
    end
  end
end
