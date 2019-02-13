# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::moku' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:hiera_config) { 'spec/fixtures/hiera/named_instances_config.yaml' }
      let(:facts) { os_facts }

      it { is_expected.to compile }

      describe '/tmp/.moku_init_first-instance.json' do
        let(:file) { '/tmp/.moku_init_first-instance.json' }

        it { is_expected.to contain_file(file).with_ensure('present') }

        [
          %r{^\s*"deploy_dir": "/www-invalid/first-instance/app",$},
          %r{^\s*"systemd_services": \["one_subservice", "another_subservice"\],$},
        ].each do |search_string|
          it { is_expected.to contain_file(file).with_content(search_string) }
        end
      end

      describe '/tmp/.moku_init_minimal-instance.json' do
        let(:file) { '/tmp/.moku_init_minimal-instance.json' }

        it { is_expected.to contain_file(file).with_ensure('present') }

        [
          %r{^\s*"deploy_dir": "/www-invalid/minimal/app",$},
          %r{^\s*"systemd_services": \[\],$},
        ].each do |search_string|
          it { is_expected.to contain_file(file).with_content(search_string) }
        end
      end
    end
  end
end
