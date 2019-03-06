# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::tools_lib::apache' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:hiera_config) { 'spec/fixtures/hiera/tools_lib_config.yaml' }

      context 'with default attributes' do
        it { is_expected.to contain_file('/srv/www/index.html') }
        it { is_expected.to contain_file('/srv/www/index.css') }
        it { is_expected.to contain_class('nebula::profile::ssl_keypair').with(common_name: 'atlassian.example.com') }
        it { is_expected.to contain_class('apache').with(docroot: '/srv/www') }
        it { is_expected.to contain_firewall('200 HTTP').with(dport: [80, 443]) }
      end
    end
  end
end
