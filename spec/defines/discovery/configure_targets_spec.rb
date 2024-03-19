# frozen_string_literal: true

# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::discovery::configure_targets' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context "with title set to example_client" do
        let(:title) { "example_client" }
        let(:params) { { port: 12345 } }

        it { is_expected.to compile }
      end
    end
  end
end
