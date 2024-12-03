# frozen_string_literal: true

require 'spec_helper'

describe 'nebula::profile::apt::mono' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it do
        expect(subject).to contain_apt__source('mono-official-stable').with(
          location: 'https://download.mono-project.com/repo/debian',
          release: 'stable-buster',
          repos: 'main',
        )
      end
    end
  end
end
