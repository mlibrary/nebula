# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::elastic::filebeat::configs::mgetit' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to contain_service('filebeat') }

      it do
        is_expected.to contain_file('/etc/filebeat/configs/mgetit.yml')
          .that_notifies('Service[filebeat]')
      end

      [
        %r{^\s+document_type: mgetit$},
        %r{paths:\n\s*- /var/log/mgetit\.default\.invalid}m,
      ].each do |line|
        it do
          is_expected.to contain_file('/etc/filebeat/configs/mgetit.yml')
            .with_content(line)
        end
      end

      context 'with a log_path of /opt/mgetit.log' do
        let(:params) { { log_path: '/opt/mgetit.log' } }

        it do
          is_expected.to contain_file('/etc/filebeat/configs/mgetit.yml')
            .with_content(%r{paths:\n\s*- /opt/mgetit\.log}m)
        end
      end
    end
  end
end
