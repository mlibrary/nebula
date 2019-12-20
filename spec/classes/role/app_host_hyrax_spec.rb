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

      it { is_expected.to compile }

      context "with class" do
        [
          'include nebula::role::umich',
          'include nebula::profile::ruby',
          'include nebula::profile::nodejs',
          'include nebula::profile::named_instances',
          'include nebula::profile::named_instances::apache',
          'include nebula::profile::mysql',
          'include nebula::profile::redis',
          'include nebula::profile::solr',
        ].each do |class_name|
          it { is_expected.to contain_class(class_name) }
        end
      end
    end
  end
end
