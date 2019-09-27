# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::tools_lib::apache' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:hiera_config) { 'spec/fixtures/hiera/tools_lib_config.yaml' }

      context 'with default attributes' do
        it { is_expected.to contain_file('/srv/www/index.html') }
        it { is_expected.to contain_file('/srv/www/index.css') }
        it { is_expected.to contain_class('nebula::profile::ssl_keypair').with(common_name: 'atlassian.example.com') }
        it { is_expected.to contain_class('apache').with(docroot: '/srv/www') }
        it { is_expected.to contain_firewall('200 HTTP').with(dport: [80, 443]) }

        it do
          is_expected.to contain_apache__vhost('atlassian.example.com ssl')
            .with_directories([{
                                'provider' => 'proxy',
                                'path'     => '*',
                                'require'  => 'all granted',
                              }, {
                                'provider' => 'location',
                                'path'     => '/synchrony',
                                'rewrites' => [{
                                  'rewrite_cond' => ['%{HTTP:UPGRADE} ^WebSocket$ [NC]', '%{HTTP:CONNECTION} Upgrade$ [NC]'],
                                  'rewrite_rule' => ['.* ws://localhost:8091%{REQUEST_URI} [P]'],
                                }],
                              }])
        end
      end

      context 'with blocked_paths set to ["/path1", "/path2"]' do
        let(:params) { { blocked_paths: %w[/path1 /path2] } }

        it do
          is_expected.to contain_apache__vhost('atlassian.example.com ssl')
            .with_directories([{
                                'provider' => 'proxy',
                                'path'     => '*',
                                'require'  => 'all granted',
                              }, {
                                'provider' => 'locationmatch',
                                'path'     => '/path1',
                                'require'  => 'all denied',
                              }, {
                                'provider' => 'locationmatch',
                                'path'     => '/path2',
                                'require'  => 'all denied',
                              }, {
                                'provider' => 'location',
                                'path'     => '/synchrony',
                                'rewrites' => [{
                                  'rewrite_cond' => ['%{HTTP:UPGRADE} ^WebSocket$ [NC]', '%{HTTP:CONNECTION} Upgrade$ [NC]'],
                                  'rewrite_rule' => ['.* ws://localhost:8091%{REQUEST_URI} [P]'],
                                }],
                              }])
        end
      end
    end
  end
end
