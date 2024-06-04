# frozen_string_literal: true
require 'spec_helper'

describe 'nebula::profile::apt::mono' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      case os
      when 'ubuntu-20.04-x86_64', 'debian-10-x86_64'
        it do
          is_expected.to contain_apt__source('mono-official-stable').with(
            location: 'https://download.mono-project.com/repo/debian',
            release: "stable-#{facts[:lsbdistcodename]}",
            repos: 'main',
          )
        end
      else
        it do
          is_expected.to contain_apt__source('mono-official-stable').with(
            location: 'https://download.mono-project.com/repo/debian',
            release: "stable-buster",
            repos: 'main',
          )
        end
      end

    end
  end
end
