# frozen_string_literal: true

require "spec_helper"

describe "nebula::profile::apt::mono" do
  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it do
        expect(subject).to contain_apt__source("mono-official-stable").with(
          source_format: "sources",
          location: ["https://download.mono-project.com/repo/debian"],
          release: "stable-buster",
          repos: ["main"],
          keyring: "/etc/apt/keyrings/mono-project.asc"
        )
      end

      it do
        expect(subject).to contain_apt__keyring("mono-project.asc").with(
          source: "puppet:///modules/nebula/apt/keyrings/mono-project.asc"
        )
      end
    end
  end
end
