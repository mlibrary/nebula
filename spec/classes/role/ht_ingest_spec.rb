# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'
require 'faker'

describe 'nebula::role::hathitrust::ingest_indexing' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:hiera_config) { 'spec/fixtures/hiera/hathitrust_config.yaml' }

      it { is_expected.to compile }

      it { is_expected.to contain_package('nfs-common') }
      it { is_expected.to contain_mount('/sdr1').with_options('auto,hard') }
      it { is_expected.to contain_mount('/htprep') }

      # default from hiera
      it { is_expected.to contain_host('mysql-sdr').with_ip('10.1.2.4') }
      it { is_expected.not_to contain_file('/etc/firewall.ipv4') }

      case os
      when 'debian-8-x86_64'
        it { is_expected.not_to contain_class('nebula::profile::base::firewall::ipv4') }
        it { is_expected.to have_firewall_resource_count(0) }
        it { is_expected.to contain_package('jhove') }
        it { is_expected.to have_apt__pin_resource_count(0) }
      when 'debian-9-x86_64'
        it { is_expected.to contain_class('nebula::profile::networking::firewall') }
        it do
          is_expected.to contain_apt__pin('buster-jhove')
            .with(codename: 'buster', packages: ['jhove'])
        end
        it { is_expected.to contain_apt__source('testing') }
        it { is_expected.to contain_apt__pin('testing').with(priority: '-10', packages: '*') }
      end
    end
  end
end
