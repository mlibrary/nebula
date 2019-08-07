# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

require_relative '../../support/contexts/with_mocked_nodes'

describe 'nebula::role::webhost::www_lib_vm' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts.merge(hostname: 'thisnode', datacenter: 'somedc') }
      let(:rolenode) { { 'ip' => Faker::Internet.ip_v4_address, 'hostname' => 'rolenode' } }
      let(:hiera_config) { 'spec/fixtures/hiera/www_lib_config.yaml' }
      include_context 'with mocked puppetdb functions', 'somedc', %w[rolenode], 'nebula::profile::haproxy' => %w[]

      it { is_expected.to compile }

      it { is_expected.to contain_class('php') }

      it { is_expected.to contain_mount('/www') }

      it { is_expected.to contain_apache__vhost('000-default-ssl').with_ssl('true') }

      it { is_expected.to contain_apache__vhost('www.lib ssl').with_ssl('true') }

      it do
        is_expected.to contain_concat_file('/usr/local/lib/cgi-bin/monitor/monitor_config.yaml')
      end

      # from hiera
      it { is_expected.to contain_host('mysql-web').with_ip('10.0.0.123') }

      it do
        is_expected.to contain_file('authz_umichlib.conf')
          .with_content(/DLPSAuthExemption/)
      end
    end
  end
end
