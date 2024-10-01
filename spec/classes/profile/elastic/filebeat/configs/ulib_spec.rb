# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::elastic::filebeat::configs::ulib' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:file) { '/etc/filebeat/configs/ulib.yml' }

      context 'with params' do
        let(:params) { { files: ['/var/log/1.log', '/var/log/logger/2.txt'] } }

        it { is_expected.to contain_service('filebeat') }

        it do
          is_expected.to contain_file(file)
            .that_notifies('Service[filebeat]')
            .with_content(%r{^\s+document_type: ulib$})
        end
        it { is_expected.to contain_file(file).with_content(%r{^    \- "/var/log/1.log"$}) }
        it { is_expected.to contain_file(file).with_content(%r{^    \- "/var/log/logger/2.txt"$}) }
      end
      context 'without params' do
        it "doesn't fail with no files specified" do
          is_expected.to compile
        end
      end
    end
  end
end
