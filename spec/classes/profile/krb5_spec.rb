# frozen_string_literal: true

# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::krb5' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to contain_package('krb5-user') }
      it { is_expected.to contain_package('libpam-krb5') }
      it { is_expected.to contain_class('nebula::profile::networking::keytab') }

      it do
        is_expected.to contain_debconf('krb5-config/default_realm')
          .with_type('string')
          .with_value('REALM.DEFAULT.INVALID')
      end

      context 'given a realm of EXAMPLE.COM' do
        let(:params) { { realm: 'EXAMPLE.COM' } }

        it do
          is_expected.to contain_debconf('krb5-config/default_realm')
            .with_type('string')
            .with_value('EXAMPLE.COM')
        end
      end
    end
  end
end
