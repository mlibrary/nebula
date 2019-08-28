# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'
require 'faker'

describe 'nebula::role::hathitrust::backup' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:hiera_config) { 'spec/fixtures/hiera/hathitrust_config.yaml' }

      it { is_expected.to compile }

      it { is_expected.to contain_package('nfs-common') }
      it { is_expected.to contain_mount('/sdr1').with_options('auto,hard,nfsvers=3,ro') }
      # causes a warning if concat fragment is included but monitor_pl isn't
      # (which we don't need on ingest servers)
      it { is_expected.not_to contain_concat_fragment('monitor nfs /sdr1') }
      it { is_expected.to contain_mount('/htprep') }

      it { is_expected.to contain_package('tivsm-ba') }

      it { is_expected.to contain_service('tsm') }
      it do
        is_expected.to contain_service('dsmcad')
          .with_ensure('stopped')
          .with_enable(false)
      end
      it { is_expected.to contain_file('/etc/init.d/tsm.service') }
    end
  end
end
