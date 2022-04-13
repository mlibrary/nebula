# frozen_string_literal: true

# Copyright (c) 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

require_relative '../../support/contexts/with_mocked_nodes'

describe 'nebula::role::webhost::fulcrum_www_and_app' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts.merge(hostname: 'thisnode', datacenter: 'somedc') }
      let(:rolenode) { { 'ip' => Faker::Internet.ip_v4_address, 'hostname' => 'rolenode' } }
      let(:hiera_config) { 'spec/fixtures/hiera/fulcrum_config.yaml' }

      include_context 'with mocked puppetdb functions', 'somedc', %w[rolenode], 'nebula::profile::haproxy' => %w[]

      it { is_expected.to compile }

      it { is_expected.to contain_class('nebula::profile::fulcrum::app') }

      it { is_expected.to contain_class('Nebula::Profile::Www_lib::Register_for_load_balancing') }

      it { is_expected.to contain_class('nebula::profile::networking::firewall::http') }

      it { is_expected.to contain_class('nebula::profile::apache') }

      it 'configures shibboleth' do
        is_expected.to contain_class('nebula::profile::shibboleth')
          .with(startup_timeout: 900)
          .with(watchdog_minutes: '*/30')
      end

      it do
        is_expected.to contain_file('/etc/apache2/mods-available/shib2.conf')
          .with_content(%r{SetHandler shib-handler})
      end

      it do
        is_expected.to contain_file('/etc/apache2/mods-enabled/shib2.conf')
          .with_ensure('link')
          .with_target('/etc/apache2/mods-available/shib2.conf')
      end

      # from hiera
      it { is_expected.to contain_host('mysql-web').with_ip('10.0.0.123') }

      it { is_expected.to contain_cron('purge apache access logs 1/2') }
      it { is_expected.to contain_cron('purge apache access logs 2/2') }
      it { is_expected.to contain_cron('shibd existence check') }
    end
  end
end
