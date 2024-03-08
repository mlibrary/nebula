# frozen_string_literal: true

require 'spec_helper'

describe 'nebula::profile::grafana_agent' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_apt__source('grafana') }
      it { is_expected.to contain_package('grafana-agent-flow') }
      it { is_expected.to contain_service('grafana-agent-flow') }
    end
  end
end
