# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::named_instance' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:hiera_config) { 'spec/fixtures/hiera/named_instances_config.yaml' }

      let(:app_params) do
        {
          'uid' => 1001,
          'gid' => 1002,
        }
      end

      let(:proxy_params) do
        {
          'public_hostname' => 'foo.default.invalid',
          'static_directories' => false,
          'single_sign_on' => 'invalid',
        }
      end

      describe 'concat_fragments' do
        let(:target) { "#{name} deploy init" }
        let(:title) { name }
        let(:path) { '/www-invalid/first-instance/app' }
        let(:users) { %w[one_user another_user] }

        context 'for first-instance' do
          let(:name) { 'first-instance' }
          let(:params) do
            {
              bind_address: '10.1.2.3',
              port: 3000,
              url_root: '/first-instance-root',
              users: users,
              subservices: %w[one_subservice another_subservice],
              source_url: 'git@github.com:mlibrary/first_invalid_default',
              path: path,
              init_directory: '/myinit',
              proxy: proxy_params,
              app: app_params,
            }
          end

          it do
            # Because of ADR-1, I'm setting this to pretty json instead
            # of regular json. Since a human will be running moku init,
            # it's easy to imagine that human wanting to look at the
            # configuration file to check that it's set up right, and
            # that's easier to do with readable json.
            is_expected.to contain_concat_file(target).with(
              path: '/myinit/first-instance.json',
              format: 'json-pretty',
            )
          end

          {
            'instance.source.url'               => '{"instance":{"source":{"url":"git@github.com:mlibrary/first_invalid_default"}}}',
            'instance.source.commitish'         => '{"instance":{"source":{"commitish":"master"}}}',
            'instance.deploy.url'               => '{"instance":{"deploy":{"url":"git@github.com:mlibrary/moku-deploy"}}}',
            'instance.deploy.commitish'         => '{"instance":{"deploy":{"commitish":"first-instance"}}}',
            'instance.infrastructure.url'       => '{"instance":{"infrastructure":{"url":"git@github.com:mlibrary/moku-infrastructure"}}}',
            'instance.infrastructure.commitish' => '{"instance":{"infrastructure":{"commitish":"first-instance"}}}',
            'instance.dev.url'                  => '{"instance":{"dev":{"url":"git@github.com:mlibrary/moku-dev"}}}',
            'instance.dev.commitish'            => '{"instance":{"dev":{"commitish":"first-instance"}}}',
            'permissions.deploy'                => '{"permissions":{"deploy":["one_user","another_user"]}}',
            'permissions.edit'                  => '{"permissions":{"edit":["one_user","another_user"]}}',
            'infrastructure.base_dir'           => '{"infrastructure":{"base_dir":"/www-invalid/first-instance/app"}}',
            'infrastructure.relative_url_root'  => '{"infrastructure":{"relative_url_root":"/first-instance-root"}}',
            'infrastructure.bind'               => '{"infrastructure":{"bind":"tcp://10.1.2.3:3000"}}',
            'deploy.deploy_dir'                 => '{"deploy":{"deploy_dir":"/www-invalid/first-instance/app"}}',
            'deploy.env'                        => '{"deploy":{"env":{"rack_env":"production","rails_env":"production"}}}',
            'deploy.systemd_services'           => '{"deploy":{"systemd_services":["one_subservice","another_subservice"]}}',
            'deploy.sites.user'                 => '{"deploy":{"sites":{"user":"first-instance"}}}',
          }.each do |fragment_title, content|
            describe fragment_title do
              it "sets #{content}" do
                is_expected.to contain_concat_fragment("#{name} deploy init #{fragment_title}").with(
                  target: target,
                  content: content,
                )
              end
            end
          end

          describe 'exported resources' do
            subject { exported_resources }

            it { is_expected.to contain_nebula__named_instance__proxy(title) }

            it do
              is_expected.to contain_nebula__named_instance__app(title).with(
                path: path,
                mysql_host: 'localhost',
                mysql_user: nil,
                mysql_password: nil,
                users: users,
              )
            end

            it do
              is_expected.to contain_nebula__named_instance__proxy(title).with(
                url_root: '/first-instance-root',
                port: 3000,
                path: path,
              )
            end
          end

          describe 'solr' do
            it { is_expected.to have_nebula__named_instance__solr_params_resource_count(0) }
            it { is_expected.not_to contain_file("#{path}/current") }

            context 'with solr params' do
              let(:params) do
                super().merge(
                  solr_cores: {
                    'somecore' => {
                      'solr_home' => '/nonexistent/solr',
                      'index' => 1,
                    },
                  },
                )
              end

              it do
                is_expected.to contain_nebula__named_instance__solr_params('somecore').with(
                  instance: title,
                  path: path,
                  solr_params: { 'solr_home' => '/nonexistent/solr', 'index' => 1 },
                )
              end
            end

            context 'with two solr cores' do
              let(:params) do
                super().merge(
                  solr_cores: {
                    'core1' => {
                      'index' => 1,
                    },
                    'core2' => {
                      'index' => 99,
                    },
                  },
                )
              end

              it { is_expected.to contain_nebula__named_instance__solr_params('core1').with_solr_params('index' => 1) }
              it { is_expected.to contain_nebula__named_instance__solr_params('core2').with_solr_params('index' => 99) }
            end
          end
        end

        context 'for minimal-instance' do
          let(:name) { 'minimal-instance' }
          let(:path) { '/www-invalid/minimal/app' }
          let(:params) do
            {
              port: 3001,
              source_url: 'git@github.com:mlibrary/nebula',
              path: path,
              init_directory: '/somewhere/init',
              proxy: proxy_params,
              app: app_params,
            }
          end

          it do
            is_expected.to contain_concat_file(target).with(
              path: '/somewhere/init/minimal-instance.json',
            )
          end

          {
            'instance.source.url'               => '{"instance":{"source":{"url":"git@github.com:mlibrary/nebula"}}}',
            'instance.source.commitish'         => '{"instance":{"source":{"commitish":"master"}}}',
            'instance.deploy.url'               => '{"instance":{"deploy":{"url":"git@github.com:mlibrary/moku-deploy"}}}',
            'instance.deploy.commitish'         => '{"instance":{"deploy":{"commitish":"minimal-instance"}}}',
            'instance.infrastructure.url'       => '{"instance":{"infrastructure":{"url":"git@github.com:mlibrary/moku-infrastructure"}}}',
            'instance.infrastructure.commitish' => '{"instance":{"infrastructure":{"commitish":"minimal-instance"}}}',
            'instance.dev.url'                  => '{"instance":{"dev":{"url":"git@github.com:mlibrary/moku-dev"}}}',
            'instance.dev.commitish'            => '{"instance":{"dev":{"commitish":"minimal-instance"}}}',
            'permissions.deploy'                => '{"permissions":{"deploy":[]}}',
            'permissions.edit'                  => '{"permissions":{"edit":[]}}',
            'deploy.deploy_dir'                 => '{"deploy":{"deploy_dir":"/www-invalid/minimal/app"}}',
            'deploy.env'                        => '{"deploy":{"env":{"rack_env":"production","rails_env":"production"}}}',
            'deploy.systemd_services'           => '{"deploy":{"systemd_services":[]}}',
            'deploy.sites.user'                 => '{"deploy":{"sites":{"user":"minimal-instance"}}}',
            'infrastructure.bind'               => '{"infrastructure":{"bind":"tcp://localhost:3001"}}',
          }.each do |fragment_title, content|
            describe fragment_title do
              it "sets #{content}" do
                is_expected.to contain_concat_fragment("#{name} deploy init #{fragment_title}").with(
                  target: target,
                  content: content,
                )
              end
            end
          end

          describe 'exported resources' do
            subject { exported_resources }

            it { is_expected.to contain_nebula__named_instance__proxy(title) }

            it do
              is_expected.to contain_nebula__named_instance__app(title).with(
                path: path,
                mysql_host: 'localhost',
                mysql_user: nil,
                mysql_password: nil,
                users: [],
              )
            end

            it do
              is_expected.to contain_nebula__named_instance__proxy(title).with(
                url_root: '/',
                port: 3001,
                path: path,
              )
            end
          end
        end
      end
    end
  end
end
