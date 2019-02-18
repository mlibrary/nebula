# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::moku' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:hiera_config) { 'spec/fixtures/hiera/named_instances_config.yaml' }
      let(:facts) { os_facts }

      it { is_expected.to compile }

      describe 'concat_fragments' do
        let(:title) { "#{name} deploy init #{fragment_title}" }
        let(:target) { "#{name} deploy init" }

        context 'for first-instance' do
          let(:name) { 'first-instance' }

          it do
            # Because of ADR-1, I'm setting this to pretty json instead
            # of regular json. Since a human will be running moku init,
            # it's easy to imagine that human wanting to look at the
            # configuration file to check that it's set up right, and
            # that's easier to do with readable json.
            is_expected.to contain_concat_file(target).with(
              path: '/etc/moku/init/first-instance.json',
              format: 'json-pretty',
            )
          end

          context 'with an init directory set' do
            let(:params) { { init_directory: init_directory } }
            let(:init_directory) { "/#{Faker::Internet.domain_word}" }

            it do
              is_expected.to contain_concat_file(target).with(
                path: "#{init_directory}/first-instance.json",
              )
            end
          end

          {
            'instance.source.url'               => '{"instance": {"source": {"url": "git@github.com:mlibrary/first_invalid_default"}}}',
            'instance.source.commitish'         => '{"instance": {"source": {"commitish": "master"}}}',
            'instance.deploy.url'               => '{"instance": {"deploy": {"url": "git@github.com:mlibrary/moku-deploy"}}}',
            'instance.deploy.commitish'         => '{"instance": {"deploy": {"commitish": "first-instance"}}}',
            'instance.infrastructure.url'       => '{"instance": {"infrastructure": {"url": "git@github.com:mlibrary/moku-infrastructure"}}}',
            'instance.infrastructure.commitish' => '{"instance": {"infrastructure": {"commitish": "first-instance"}}}',
            'instance.dev.url'                  => '{"instance": {"dev": {"url": "git@github.com:mlibrary/moku-dev"}}}',
            'instance.dev.commitish'            => '{"instance": {"dev": {"commitish": "first-instance"}}}',
            'permissions.deploy'                => '{"permissions": {"deploy": ["one_user","another_user"]}}',
            'permissions.edit'                  => '{"permissions": {"edit": ["one_user","another_user"]}}',
            'deploy.deploy_dir'                 => '{"deploy": {"deploy_dir": "/www-invalid/first-instance/app"}}',
            'deploy.env.rack_env'               => '{"deploy": {"env": {"rack_env": "production"}}}',
            'deploy.systemd_services'           => '{"deploy": {"systemd_services": ["one_subservice","another_subservice"]}}',
            'deploy.sites.user'                 => '{"deploy": {"sites": {"user": "first-instance"}}}',
          }.each do |fragment_title, content|
            describe fragment_title do
              let(:fragment_title) { fragment_title }

              it "sets #{content}" do
                is_expected.to contain_concat_fragment(title).with(
                  target: target,
                  content: content,
                )
              end
            end
          end
        end

        context 'for minimal-instance' do
          let(:name) { 'minimal-instance' }

          it do
            is_expected.to contain_concat_file(target).with(
              path: '/etc/moku/init/minimal-instance.json',
            )
          end

          {
            'instance.source.url'               => '{"instance": {"source": {"url": "git@github.com:mlibrary/nebula"}}}',
            'instance.source.commitish'         => '{"instance": {"source": {"commitish": "master"}}}',
            'instance.deploy.url'               => '{"instance": {"deploy": {"url": "git@github.com:mlibrary/moku-deploy"}}}',
            'instance.deploy.commitish'         => '{"instance": {"deploy": {"commitish": "minimal-instance"}}}',
            'instance.infrastructure.url'       => '{"instance": {"infrastructure": {"url": "git@github.com:mlibrary/moku-infrastructure"}}}',
            'instance.infrastructure.commitish' => '{"instance": {"infrastructure": {"commitish": "minimal-instance"}}}',
            'instance.dev.url'                  => '{"instance": {"dev": {"url": "git@github.com:mlibrary/moku-dev"}}}',
            'instance.dev.commitish'            => '{"instance": {"dev": {"commitish": "minimal-instance"}}}',
            'permissions.deploy'                => '{"permissions": {"deploy": []}}',
            'permissions.edit'                  => '{"permissions": {"edit": []}}',
            'deploy.deploy_dir'                 => '{"deploy": {"deploy_dir": "/www-invalid/minimal/app"}}',
            'deploy.env.rack_env'               => '{"deploy": {"env": {"rack_env": "production"}}}',
            'deploy.systemd_services'           => '{"deploy": {"systemd_services": []}}',
            'deploy.sites.user'                 => '{"deploy": {"sites": {"user": "minimal-instance"}}}',
          }.each do |fragment_title, content|
            describe fragment_title do
              let(:fragment_title) { fragment_title }

              it "sets #{content}" do
                is_expected.to contain_concat_fragment(title).with(
                  target: target,
                  content: content,
                )
              end
            end
          end
        end
      end
    end
  end
end
