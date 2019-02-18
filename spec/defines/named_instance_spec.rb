# frozen_string_literal: true

# Copyright (c) 2018-2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::named_instance' do
  subservice_list = ['resque-pool', 'mailman']
  let(:subservices) { subservice_list }
  let(:path) { '/hydra-dev/some/where/myapp-mystage' }
  let(:title) { 'myapp-mystage' }
  let(:public_hostname) { 'app.default.invalid' }
  let(:port) { 30_000 }
  let(:uid) { 30_001 }
  let(:gid) { 20_001 }
  let(:pubkey) { 'somepublickey' }
  let(:sendfile_path) { '/app/storage' }
  let(:puma_wrapper) { '/l/local/bin/puma_wrapper' }
  let(:puma_config) { 'config/fauxpaas_puma.rb' }
  let(:users) { %w[alice solr] }
  let(:mysql_user) { 'abcde' }
  let(:mysql_password) { '12345' }
  let(:params) do
    {
      path: path,
      public_hostname: public_hostname,
      port: port,
      uid: uid,
      gid: gid,
      subservices: subservices,
      pubkey: pubkey,
      sendfile_path: sendfile_path,
      puma_wrapper: puma_wrapper,
      puma_config: puma_config,
      users: users,
      mysql_user: mysql_user,
      mysql_password: mysql_password,
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:hiera_config) { 'spec/fixtures/hiera/ssh_keys_config.yaml' }

      it { is_expected.to compile.with_all_deps }

      describe 'group' do
        it { is_expected.to contain_group(title).with(gid: gid) }
      end

      describe 'existing users' do
        it 'adds the passed users' do
          users.each do |user|
            is_expected.to contain_exec("#{user} #{title} membership")
          end
        end
        it { is_expected.to contain_exec("invalid_normal_admin #{title} membership") }
        it { is_expected.to contain_exec("invalid_special_admin #{title} membership") }
        it { is_expected.to contain_exec("invalid_noauth_admin #{title} membership") }
      end

      describe 'exported resources' do
        subject { exported_resources }

        it 'exports a proxied_app' do
          is_expected.to contain_nebula__proxied_app(title)
        end

        context 'with a random hostname and datacenter' do
          let(:hostname) { Faker::Internet.domain_word }
          let(:datacenter) { Faker::Internet.domain_word }
          let(:facts) do
            super().merge(hostname: hostname,
                          datacenter: datacenter)
          end

          it 'exports a concat_fragment with hostname => datacenter' do
            is_expected.to contain_concat_fragment("#{title} deploy init deploy.sites.nodes.#{hostname}").with(
              target: "#{title} deploy init",
              content: "{\"deploy\": {\"sites\": {\"nodes\": {\"#{hostname}\": \"#{datacenter}\"}}}}",
            )
          end
        end
      end

      describe 'application user' do
        let(:home) { "/var/local/#{title}" }

        it { is_expected.to contain_user(title).with(uid: uid) }
        it { is_expected.to contain_user(title).with(gid: gid) }
        it { is_expected.to contain_user(title).with(home: home) }
        it { is_expected.to contain_user(title).with(shell: '/bin/bash') }
        it { is_expected.to contain_user(title).with(system: true) }
      end

      describe 'application user home dir' do
        let(:home) { "/var/local/#{title}" }

        it { is_expected.to contain_file(home).with(ensure: 'directory') }
        it { is_expected.to contain_file(home).with(mode: '0700') }
        it { is_expected.to contain_file(home).with(owner: uid) }
        it { is_expected.to contain_file(home).with(group: gid) }
      end

      describe 'authorized key' do
        it { is_expected.to contain_ssh_authorized_key("#{title} pubkey").with(ensure: 'present') }
        it { is_expected.to contain_ssh_authorized_key("#{title} pubkey").with(user: title) }
        it { is_expected.to contain_ssh_authorized_key("#{title} pubkey").with(type: 'ssh-rsa') }
        it { is_expected.to contain_ssh_authorized_key("#{title} pubkey").with(key: pubkey) }
      end

      describe 'path' do
        it { is_expected.to contain_file(path).with(ensure: 'directory') }
        it { is_expected.to contain_file(path).with(mode: '2775') }
        it { is_expected.to contain_file(path).with(owner: uid) }
        it { is_expected.to contain_file(path).with(group: gid) }
      end

      describe 'old puma systemd' do
        let(:old_puma) { "/etc/systemd/system/app-puma@#{title}.service.d" }

        it { is_expected.to contain_file(old_puma).with(ensure: 'absent') }
        it { is_expected.to contain_file(old_puma).with(recurse: true) }
        it { is_expected.to contain_file(old_puma).with(force: true) }
      end

      describe 'old resque-pool systemd' do
        let(:old_resque) { "/etc/systemd/system/resque-pool@#{title}.service.d" }

        it { is_expected.to contain_file(old_resque).with(ensure: 'absent') }
        it { is_expected.to contain_file(old_resque).with(recurse: true) }
        it { is_expected.to contain_file(old_resque).with(force: true) }
      end

      describe 'new systemd target' do
        let(:target) { "/etc/systemd/system/#{title}.target" }

        it { is_expected.to contain_file(target).with(ensure: 'present') }
        it { is_expected.to contain_file(target).with(mode: '0644') }
        it { is_expected.to contain_file(target).with(owner: 'root') }
        it { is_expected.to contain_file(target).with(group: 'root') }
        it 'Wants every subservice' do
          subservices.each do |sub|
            is_expected.to contain_file(target).with_content(
              %r{^Wants=#{sub}@#{title}\.service$},
            )
          end
        end
        it 'Requires puma' do
          is_expected.to contain_file(target).with_content(
            %r{^Requires=puma@#{title}\.service$},
          )
        end
      end

      describe 'new puma systemd' do
        let(:puma) { "/etc/systemd/system/puma@#{title}.service" }

        it { is_expected.to contain_file(puma).with(ensure: 'present') }
        it { is_expected.to contain_file(puma).with(mode: '0644') }
        it { is_expected.to contain_file(puma).with(owner: 'root') }
        it { is_expected.to contain_file(puma).with(group: 'root') }
        it { is_expected.to contain_file(puma).with_content(%r{^PartOf=#{title}\.target$}) }
        it { is_expected.to contain_file(puma).with_content(%r{^UMask=0002$}) }
        it { is_expected.to contain_file(puma).with_content(%r{^User=#{title}$}) }
        it { is_expected.to contain_file(puma).with_content(%r{^Group=#{title}$}) }
        it { is_expected.to contain_file(puma).with_content(%r{^Environment=\"RBENV_ROOT=/opt/rbenv\"$}) }
        it { is_expected.to contain_file(puma).with_content(%r{^Environment=\"RAILS_ENV=production"$}) }
        it { is_expected.to contain_file(puma).with_content(%r{^WorkingDirectory=#{path}/current$}) }
        it { is_expected.to contain_file(puma).with_content(%r{^ExecStart=#{puma_wrapper}$}) }
        it { is_expected.to contain_file(puma).with_content(%r{^TimeoutStartSec=[0-9]+$}) }
      end

      describe 'subservices' do
        subservice_list.each do |subservice|
          describe "example subservice \"#{subservice}\"" do
            let(:subservice_file) { "/etc/systemd/system/#{subservice}@#{title}.service" }

            it { is_expected.to contain_file(subservice_file).with(ensure: 'present') }
            it { is_expected.to contain_file(subservice_file).with(mode: '0644') }
            it { is_expected.to contain_file(subservice_file).with(owner: 'root') }
            it { is_expected.to contain_file(subservice_file).with(group: 'root') }
            it { is_expected.to contain_file(subservice_file).with_content(%r{^PartOf=#{title}\.target$}) }
            it { is_expected.to contain_file(subservice_file).with_content(%r{^UMask=0002$}) }
            it { is_expected.to contain_file(subservice_file).with_content(%r{^User=#{title}$}) }
            it { is_expected.to contain_file(subservice_file).with_content(%r{^Group=#{title}$}) }
            it { is_expected.to contain_file(subservice_file).with_content(%r{^Environment=\"RBENV_ROOT=/opt/rbenv\"$}) }
            it { is_expected.to contain_file(subservice_file).with_content(%r{^Environment=\"RAILS_ENV=production"$}) }
            it { is_expected.to contain_file(subservice_file).with_content(%r{^WorkingDirectory=#{path}/current$}) }
            it { is_expected.to contain_file(subservice_file).with_content(%r{^ExecStart=/opt/rbenv/bin/rbenv exec bundle exec bin/#{subservice}$}) }
            it { is_expected.to contain_file(subservice_file).with_content(%r{^TimeoutStartSec=[0-9]+$}) }
          end
        end
      end

      describe 'old sudoers' do
        let(:old_sudoers) { "/etc/sudoers.d/app-puma-#{title}" }

        it { is_expected.to contain_file(old_sudoers).with(ensure: 'absent') }
      end

      describe 'new sudoers' do
        let(:new_sudoers) { "/etc/sudoers.d/#{title}" }

        it { is_expected.to contain_file(new_sudoers).with(ensure: 'present') }
        it { is_expected.to contain_file(new_sudoers).with(mode: '0640') }
        it { is_expected.to contain_file(new_sudoers).with(owner: 'root') }
        it { is_expected.to contain_file(new_sudoers).with(group: 'root') }
        it do
          is_expected.to contain_file(new_sudoers).with_content(
            %r{^\%#{title} ALL=\(root\) NOPASSWD: /bin/systemctl stop #{title}.target$},
          )
        end
        it do
          is_expected.to contain_file(new_sudoers).with_content(
            %r{^\%#{title} ALL=\(root\) NOPASSWD: /bin/systemctl start #{title}.target$},
          )
        end
        it do
          is_expected.to contain_file(new_sudoers).with_content(
            %r{^\%#{title} ALL=\(root\) NOPASSWD: /bin/systemctl restart #{title}.target$},
          )
        end
        it do
          is_expected.to contain_file(new_sudoers).with_content(
            %r{^\%#{title} ALL=\(root\) NOPASSWD: /bin/systemctl status #{title}.target$},
          )
        end
        it do
          is_expected.to contain_file(new_sudoers).with_content(
            %r{^\%#{title} ALL=\(root\) NOPASSWD: /bin/journalctl$},
          )
        end
      end

      describe 'database' do
        it do
          is_expected.to contain_mysql__db(title).with(
            user: mysql_user,
            password: mysql_password,
            host: '%',
            grant: ['ALL'],
          )
        end

        # Without the mysql_exec_path parameter, this fails with the error:
        # Unknown variable: 'mysql::params::exec_path' We don't entirely
        # understand why, but adding that doesn't appear to harm anything,so
        # we're leaving it here to keep the tests passing.
        #
        # It doesn't have to be an empty string in particular, but it does need
        # to be set to something.
        it { is_expected.to contain_mysql__db(title).with_mysql_exec_path('') }

        context 'when create_database is false' do
          let(:params) { super().merge(create_database: false) }

          it { is_expected.not_to contain_mysql__db(title) }
        end

        context 'without mysql_user' do
          let(:params) { super().reject { |k, _| k == :mysql_user } }

          it { is_expected.not_to contain_mysql__db(title) }
        end

        context 'without mysql_password' do
          let(:params) { super().reject { |k, _| k == :mysql_password } }

          it { is_expected.not_to contain_mysql__db(title) }
        end
      end

      describe 'solr' do
        it { is_expected.to have_nebula__named_instance__solr_core_resource_count(0) }
        it { is_expected.not_to contain_file("#{path}/current") }

        context 'with solr params' do
          let(:params) do
            super().merge(
              solr_cores: {
                'somecore' => {
                  'solr_home' => '/nonexistent/solr',
                },
              },
            )
          end

          it do
            is_expected.to contain_nebula__named_instance__solr_core('somecore').with(
              instance_title: title,
              instance_path: path,
            )
          end
        end

        context 'with two solr cores' do
          let(:params) do
            super().merge(
              solr_cores: {
                'core1' => {
                  'solr_home' => '/nonexistent/solr',
                },
                'core2' => {
                  'solr_home' => '/nonexistent/solr',
                },
              },
            )
          end

          it { is_expected.to contain_nebula__named_instance__solr_core('core1') }
          it { is_expected.to contain_nebula__named_instance__solr_core('core2') }
        end
      end
    end
  end
end
