# frozen_string_literal: true

# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::discovery::listen_on_port' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context "with title set to example_service" do
        let(:title) { "example_service" }
        let(:params) do
          {
            concat_target: "/path/to/config_file",
            concat_content: <<~FILE
              [main]
              ip_address = $IP_ADDRESS
            FILE
          }
        end

        it { is_expected.to compile }

        it do
          expect(exported_resources).to contain_concat_fragment("#{title} #{facts[:hostname]}")
            .with_content(/#{facts[:ipaddress]}/)
        end
      end
    end
  end
end
