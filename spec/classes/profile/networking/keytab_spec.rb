# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::networking::keytab' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.not_to contain_file('/etc/krb5.keytab') }

      context 'when given an existing keytab file' do
        let(:params) { { keytab: 'nebula/keytab.fake' } }

        it do
          is_expected.to contain_file('/etc/krb5.keytab').with(
            mode: '0600',
            content: %r{^This is not a real keytab.},
          )
        end
      end

      context 'when given a nonexistent keytab file' do
        let(:params) { { keytab: 'nebula/keytab.not_a_file' } }

        it { is_expected.not_to contain_file('/etc/krb5.keytab') }
      end

      context 'when given a keytab source and no keytab' do
        let(:params) { { keytab_source: 'alternate source' } }

        it { is_expected.not_to contain_file('/etc/krb5.keytab') }
      end

      context 'when given a keytab source and a nonexistent keytab' do
        let :params do
          {
            keytab: 'nebula/keytab.not_a_file',
            keytab_source: 'alternate source',
          }
        end

        it { is_expected.not_to contain_file('/etc/krb5.keytab') }
      end

      context 'when given a keytab source and a real keytab' do
        let :params do
          {
            keytab: 'nebula/keytab.fake',
            keytab_source: 'alternate source',
          }
        end

        it do
          is_expected.to contain_file('/etc/krb5.keytab').with(
            mode: '0600',
            source: 'alternate source',
          )
        end
      end
    end
  end
end
