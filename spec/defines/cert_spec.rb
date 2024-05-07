# frozen_string_literal: true

# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::cert' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with title set to example.invalid' do
        let(:title) { 'example.invalid' }

        it { is_expected.to contain_class('letsencrypt').with_email('contact@default.invalid') }

        it do
          is_expected.to contain_letsencrypt__certonly('example.invalid')
            .with_domains(['example.invalid'])
            .with_plugin('standalone')
            .with_manage_cron(true)
            .with_cron_output('log')
        end

        it do
          is_expected.to contain_firewall('200 HTTP')
            .with_proto('tcp')
            .with_dport(80)
            .with_state('NEW')
            .with_action('accept')
        end

        context 'and with additional_domains set to sub.example.invalid' do
          let(:params) { { additional_domains: ['sub.example.invalid'] } }

          it do
            is_expected.to contain_letsencrypt__certonly('example.invalid')
              .with_domains(%w[example.invalid sub.example.invalid])
              .with_plugin('standalone')
          end
        end

        context 'and with webroot set to /var/www' do
          let(:params) { { webroot: '/var/www' } }

          it do
            is_expected.to contain_letsencrypt__certonly('example.invalid')
              .with_plugin('webroot')
              .with_webroot_paths(['/var/www'])
              .with_manage_cron(true)
              .with_cron_output('log')
          end
        end

        context 'and with webroot set to [/var/www]' do
          let(:params) { { webroot: ['/var/www'] } }

          it do
            is_expected.to contain_letsencrypt__certonly('example.invalid')
              .with_plugin('webroot')
              .with_webroot_paths(['/var/www'])
          end
        end
      end
    end
  end
end
