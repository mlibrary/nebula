# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::apt' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      if os.start_with? "debian"
        it do
          is_expected.to contain_class('apt').with(
            purge: {
              'sources.list'   => true,
              'sources.list.d' => true,
              'preferences'    => true,
              'preferences.d'  => true,
            },
            update: {
              'frequency' => 'daily',
            },
          )
        end

        it 'sets apt to never install recommended packages' do
          is_expected.to contain_file('/etc/apt/apt.conf.d/99no-recommends')
            .with_content(%r{^APT::Install-Recommends "0";$})
            .with_content(%r{^APT::Install-Suggests "0";$})
        end

        it do
          is_expected.to contain_apt__source('main').with(
            location: 'http://ftp.us.debian.org/debian/',
            repos: 'main contrib non-free',
          )
        end

        it { is_expected.to contain_apt__source('security').with_repos('main contrib non-free') }

        case os
        when 'debian-9-x86_64'
          it { is_expected.to contain_apt__source('security').with_release("#{facts[:lsbdistcodename]}/updates") }
        when 'debian-10-x86_64'
          it { is_expected.to contain_apt__source('security').with_release("#{facts[:lsbdistcodename]}/updates") }
        else
          it { is_expected.to contain_apt__source('security').with_release("#{facts[:lsbdistcodename]}-security") }
        end

        it do
          is_expected.to contain_apt__source('puppet').with(
            location: 'http://apt.puppetlabs.com',
            repos: 'puppet5',
          )
        end

        it do
          is_expected.to contain_file('/etc/apt/apt.conf.d/99force-ipv4')
            .with_content(%r{^Acquire::ForceIPv4 "true";$})
        end

        context 'when given a mirror of http://debian.uchicago.edu/' do
          let(:params) { { mirror: 'http://debian.uchicago.edu/' } }

          it do
            is_expected.to contain_apt__source('main')
              .with_location('http://debian.uchicago.edu/')
          end
        end

        context 'when given a puppet_repo of PC1' do
          let(:params) { { puppet_repo: 'PC1' } }

          it { is_expected.to contain_apt__source('puppet').with_repos('PC1') }
        end
      end

      it { is_expected.to contain_apt__source('local').with_architecture('amd64') }

      case os
      when 'debian-8-x86_64'
        it do
          is_expected.to contain_apt__source('security')
            .with_location('http://security.debian.org/')
        end
      when 'debian-9-x86_64'
        it do
          is_expected.to contain_apt__source('security')
            .with_location('http://security.debian.org/debian-security')
        end

        it do
          is_expected.to contain_apt__source('updates').with(
            location: 'http://ftp.us.debian.org/debian/',
            release: "#{facts[:lsbdistcodename]}-updates",
            repos: 'main contrib non-free',
          )
        end

        context 'when given a local repo' do
          let(:params) do
            { local_repo:
                             { 'location' => 'http://somehost.example.invalid/debs',
                               'key'      => { 'id' => '12345678', 'source' => 'http://somehost.example.invalid/repo-key.gpg' } } }
          end

          it do
            is_expected.to contain_apt__source('local').with(location: 'http://somehost.example.invalid/debs',
                                                             architecture: 'amd64',
                                                             release: 'stretch',
                                                             key: params[:local_repo]['key'],
                                                             repos: 'main')
          end
        end

        it { is_expected.not_to contain_class('apt::backports') }

        context 'when abc is installed from backports' do
          let(:facts) { os_facts.merge(installed_backports: ['abc']) }

          it do
            is_expected.to contain_class('apt::backports')
              .with_location('http://ftp.us.debian.org/debian/')
          end
        end
      end

      it { is_expected.not_to contain_apt__source('hp') }

      context 'on an HPE machine' do
        let(:facts) { os_facts.merge('dmi' => { 'manufacturer' => 'HPE' }) }

        it do
          is_expected.to contain_apt__source('hp').with(
            location: 'http://downloads.linux.hpe.com/SDR/repo/mcp/debian',
            release: "#{facts[:lsbdistcodename]}/current",
            repos: 'non-free',
          )
        end

        context 'with ubuntu instead of debian' do
          let(:facts) do
            os_facts.merge('dmi' => { 'manufacturer' => 'HPE' },
                           'operatingsystem' => 'Ubuntu')
          end

          it do
            is_expected.to contain_apt__source('hp').with(
              location: 'http://downloads.linux.hpe.com/SDR/repo/mcp/debian',
              release: "#{facts[:lsbdistcodename]}/current",
              repos: 'non-free',
            )
          end
        end
      end
    end
  end
end
