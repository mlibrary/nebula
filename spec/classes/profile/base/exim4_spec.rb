# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::base::exim4' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:fqdn) { facts[:fqdn] }

      it do
        is_expected.to contain_service('exim4').with(
          ensure: 'running',
          enable: true,
          require: 'Package[exim4]',
        )
      end

      [
        '/etc/aliases',
        '/etc/email-addresses',
      ].each do |filename|
        it do
          is_expected.to contain_file_line("#{filename}: root email").with(
            path: filename,
            match: '^root: ',
            line: 'root: root@default.invalid',
            notify: 'Exec[load new email aliases]',
            require: 'Package[exim4]',
          )
        end
      end

      context 'when given root_email of majordomo@email.gov' do
        let(:params) { { root_email: 'majordomo@email.gov' } }

        [
          '/etc/aliases',
          '/etc/email-addresses',
        ].each do |filename|
          it do
            is_expected.to contain_file_line("#{filename}: root email").with(
              path: filename,
              match: '^root: ',
              line: 'root: majordomo@email.gov',
              notify: 'Exec[load new email aliases]',
            )
          end
        end
      end

      it do
        is_expected.to contain_file('/etc/mailname')
          .with_content("#{fqdn}\n")
          .that_notifies('Exec[update exim4 config]')
      end

      it do
        is_expected.to contain_file('/etc/exim4/update-exim4.conf.conf')
          .with_content(%r{^dc_other_hostnames='#{fqdn}'$})
          .with_content(%r{^dc_relay_domains='exim\.default\.invalid'$})
          .that_notifies('Exec[update exim4 config]')
          .that_requires('Package[exim4]')
      end

      context 'given a relay_domain of umich.edu' do
        let(:params) { { relay_domain: 'umich.edu' } }

        it do
          is_expected.to contain_file('/etc/exim4/update-exim4.conf.conf')
            .with_content(%r{^dc_relay_domains='umich\.edu'$})
        end
      end

      it { is_expected.to contain_package('exim4') }

      it do
        is_expected.to contain_exec('load new email aliases').with(
          command: '/usr/bin/newaliases',
          refreshonly: true,
        )
      end

      it do
        is_expected.to contain_exec('update exim4 config').with(
          command: '/usr/sbin/update-exim4.conf',
          refreshonly: true,
          notify: 'Service[exim4]',
        )
      end
    end
  end
end
