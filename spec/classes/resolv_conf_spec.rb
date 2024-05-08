# frozen_string_literal: true

require 'spec_helper'

describe 'nebula::resolv_conf' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it 'removes resolvconf package if present' do
        is_expected.to contain_package('resolvconf').with_ensure('absent')
      end

      it 'contains expected resolv.conf file' do
        is_expected.to contain_file('/etc/resolv.conf')
          .with_owner('root')
          .with_group('root')
          .with_mode('0644')
          .with_content(/^#.*puppet/)
          .with_content(/^search searchpath\.default\.invalid$/)
          .with_content(/^nameserver 5.5.5.5\nnameserver 4.4.4.4$/)
      end

      context 'different nameservers' do
        let(:params) { { nameservers: ['3.3.3.3', '2.2.2.2', '1.1.1.1'] } }

        it do
          is_expected.to contain_file('/etc/resolv.conf')
            .with_content(/^#.*puppet/)
            .with_content(/^search searchpath\.default\.invalid$/)
            .with_content(/^nameserver 3.3.3.3\nnameserver 2.2.2.2\nnameserver 1.1.1.1$/)
        end
      end

      context 'searchpath set to []' do
        let(:params) { { searchpath: [] } }

        it do
          is_expected.to contain_file('/etc/resolv.conf')
            .with_content(/^#.*puppet/)
            .without_content(/^search/)
            .with_content(/^nameserver 5.5.5.5\nnameserver 4.4.4.4$/)
        end
      end

      context 'custom file mode' do
        let(:params) { { mode: '0664' } }

        it do
          is_expected.to contain_file('/etc/resolv.conf')
            .with_content(/^#.*puppet/)
            .with_mode('0664')
        end
      end

    end
  end
end
