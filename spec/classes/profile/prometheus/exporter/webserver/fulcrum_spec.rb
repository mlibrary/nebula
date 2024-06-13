# frozen_string_literal: true

# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::prometheus::exporter::webserver::fulcrum' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:base) { "nebula::profile::prometheus::exporter::webserver::base" }

      it { is_expected.to compile }
      it { is_expected.to contain_class(base).with_target("fulcrum") }
    end
  end
end
