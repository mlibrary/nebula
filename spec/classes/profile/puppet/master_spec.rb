# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::puppet::master' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it do
        is_expected.to contain_service('puppetserver').with(
          ensure: 'running',
          enable: true,
          hasrestart: true,
          require: 'Exec[/opt/rbenv/shims/r10k deploy environment production]',
        )
      end

      it do
        is_expected.to contain_exec(
          '/opt/rbenv/shims/r10k deploy environment production',
        ).with_creates('/etc/puppetlabs/code/environments/production')
          .that_requires('File[/etc/puppetlabs/r10k/r10k.yaml]')
          .that_notifies('Exec[/opt/rbenv/shims/librarian-puppet update]')
      end

      it do
        is_expected.to contain_exec('/opt/rbenv/shims/librarian-puppet update')
          .with_refreshonly(true)
          .with_cwd('/etc/puppetlabs/code/environments/production')
      end

      it do
        is_expected.to contain_file('/etc/puppetlabs/r10k/r10k.yaml')
          .that_requires('File[/etc/puppetlabs/r10k]')
          .with_content(%r{^cachedir: /var/cache/r10k$})
      end

      it do
        is_expected.to contain_file('/etc/puppetlabs/r10k')
          .with_ensure('directory')
          .that_requires('Package[puppetserver]')
      end

      it do
        is_expected.to contain_file('/etc/puppetlabs/puppet/fileserver.conf')
          .with_content(%r{\[ssl-certs\]\n *path /default_invalid/etc/ssl}m)
          .with_content(%r{\[repos\]\n *path /default_invalid/opt/repos}m)
          .that_requires('Package[puppetserver]')
      end

      it do
        is_expected.to contain_file('/etc/puppetlabs/puppet/autosign.conf')
          .that_requires('Package[puppetserver]')
          .without_content(%r{^[^#]})
      end

      context 'when given some trusted certnames' do
        let(:params) { { autosign_whitelist: %w[aaa bbb] } }

        it do
          is_expected.to contain_file('/etc/puppetlabs/puppet/autosign.conf')
            .with_content(%r{^aaa$})
            .with_content(%r{^bbb$})
        end
      end

      it do
        is_expected.to contain_package('puppetserver')
          .that_requires(['Rbenv::Gem[r10k]', 'Rbenv::Gem[librarian-puppet]'])
      end

      it do
        is_expected.to contain_rbenv__gem('r10k').with(
          ruby_version: '2.4.3',
          require: [
            'Class[Nebula::Profile::Ruby]',
            'Rbenv::Build[2.4.3]',
          ],
        )
      end

      it do
        is_expected.to contain_rbenv__gem('librarian-puppet').with(
          ruby_version: '2.4.3',
          require: [
            'Class[Nebula::Profile::Ruby]',
            'Rbenv::Build[2.4.3]',
          ],
        )
      end

      it do
        is_expected.to contain_tidy(
          '/opt/puppetlabs/server/data/puppetserver/reports',
        ).with(
          age: '1h',
          recurse: true,
        )
      end

      context 'when told reports live in /var/lib' do
        let(:params) { { reports_dir: '/var/lib' } }

        it { is_expected.to contain_tidy('/var/lib').with_age('1h') }
        it { is_expected.to contain_tidy('/var/lib').with_recurse(true) }
      end
    end
  end
end
