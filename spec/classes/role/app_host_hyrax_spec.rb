# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'
require 'faker'

describe 'nebula::role::app_host::hyrax' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:hiera_config) { 'spec/fixtures/hiera/hyrax_config.yaml' }

      it { is_expected.to compile }

      context 'with class' do
        [
          'nebula::role::umich',
          'nebula::profile::ruby',
          'nebula::profile::nodejs',
          'nebula::profile::named_instances',
          'nebula::profile::named_instances::apache',
          'nebula::profile::mysql',
          'nebula::profile::redis',
          'nebula::profile::solr',
        ].each do |class_name|
          it { is_expected.to contain_class(class_name) }
        end
      end
    end
  end
end
