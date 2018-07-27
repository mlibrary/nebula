# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::named_instance' do
  subservice_list = ['resque-pool', 'mailman']
  let(:subservices) { subservice_list }
  let(:path) { '/hydra-dev/some/where/myapp-mystage' }
  let(:title) { 'myapp-mystage' }
  let(:uid) { 30_001 }
  let(:gid) { 20_001 }
  let(:pubkey) { 'somepublickey' }
  let(:puma_config) { 'config/fauxpaas_puma.rb' }
  let(:users) { %w[alice solr] }
  let(:params) do
    {
      path: path,
      uid: uid,
      gid: gid,
      subservices: subservices,
      pubkey: pubkey,
      puma_config: puma_config,
      users: users,
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

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
        it { is_expected.to contain_file(puma).with_content(%r{^ExecStart=/opt/rbenv/bin/rbenv exec puma -C #{puma_config}$}) }
        it { is_expected.to contain_file(puma).with_content(%r{^TimeoutStartSec=20$}) }
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
            it { is_expected.to contain_file(subservice_file).with_content(%r{^TimeoutStartSec=20$}) }
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
    end
  end
end
