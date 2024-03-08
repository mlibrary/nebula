# frozen_string_literal: true

require 'spec_helper'

describe 'nebula::profile::puppet::client_cert' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do      
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_concat__fragment('client cert') }
      it { is_expected.to contain_concat__fragment('client key') }
    end
  end
end
