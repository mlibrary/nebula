# frozen_string_literal: true

# Copyright (c) 2018,2021 The Regents of the University of Michigan.
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
      it { is_expected.to contain_mount('/sdr1').with_options('auto,hard,nfsvers=3') }
      # causes a warning if concat fragment is included but monitor_pl isn't
      # (which we don't need on ingest servers)
      it { is_expected.not_to contain_concat_fragment('monitor nfs /sdr1') }
      it { is_expected.to contain_mount('/htprep') }

      # default from hiera
      it { is_expected.to contain_host('mysql-sdr').with_ip('10.1.2.4') }

      case os
      when 'debian-8-x86_64'
        it { is_expected.to contain_package('jhove') }
        it { is_expected.to have_apt__pin_resource_count(0) }
      when 'debian-9-x86_64'
        it do
          is_expected.to contain_apt__pin('buster-jhove')
            .with(codename: 'buster', packages: ['jhove', 'libjaxb-api-java', 'libactivation-java'])
        end
        it { is_expected.to contain_apt__source('buster') }
        it { is_expected.to contain_apt__pin('buster').with(priority: '-10', packages: '*') }

      end

      # not specified explicitly as a usergroup, just brought in as part of 'all groups'
      it { is_expected.to contain_group('htprod') }
      it { is_expected.to contain_group('htingest') }
      # not specified explicitly - realized through Nebula::Usergroup[htingest]
      it { is_expected.to contain_user('htingest') }
      it { is_expected.not_to contain_user('htweb') }

      it { is_expected.to contain_service('feedd').with_enable(true) }
      it { is_expected.to contain_package('clamav-daemon') }
      it { is_expected.to contain_service('clamav-daemon').with_enable(true) }

      it do
        is_expected.to contain_file('/etc/systemd/system/feedd.service')
          .with_content(%r{HTFEED_CONFIG=/default/feedd.yaml})
      end
    end
  end
end
