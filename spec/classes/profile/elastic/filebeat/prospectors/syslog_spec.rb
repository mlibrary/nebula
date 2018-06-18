# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::elastic::filebeat::prospectors::syslog' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to contain_service('filebeat') }

      it do
        is_expected.to contain_file('/etc/filebeat/prospectors/syslog.yml')
          .that_notifies('Service[filebeat]')
          .with_content(%r{^\s+document_type: syslog$})
      end
    end
  end
end
