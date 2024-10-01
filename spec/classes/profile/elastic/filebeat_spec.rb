# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::elastic::filebeat' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it do
        is_expected.to contain_service('filebeat').with(
          ensure: 'running',
          enable: true,
        )
      end

      it { is_expected.to contain_package('filebeat') }

      it do
        is_expected.to contain_file('/etc/filebeat/filebeat.yml').with(
          ensure: 'present',
          require: 'Package[filebeat]',
          notify: 'Service[filebeat]',
          mode: '0644',
        )
      end

      [
        %r{^\s*config_dir: configs$},
        %r{^\s*hosts:.*"logstash.umdl.umich.edu:5044"},
      ].each do |content|
        it { is_expected.to contain_file('/etc/filebeat/filebeat.yml').with_content(content) }
      end

      it do
        is_expected.to contain_file('/etc/filebeat/configs').with(
          ensure: 'directory',
          require: 'Package[filebeat]',
        )
      end
    end
  end
end
