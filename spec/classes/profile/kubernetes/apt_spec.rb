# frozen_string_literal: true

require "spec_helper"

describe "nebula::profile::kubernetes::apt" do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      context "with no kubernetes hiera config" do
        it do
          expect(subject).to contain_apt__source("kubernetes")
            .with_location("https://pkgs.k8s.io/core:/stable:/vX.YZ/deb/")
            .with_release("/")
        end
      end

      context "with a kubernetes hiera config" do
        let(:hiera_config) { "spec/fixtures/hiera/kubernetes/first_cluster_config.yaml" }

        it do
          expect(subject).to contain_apt__source("kubernetes")
            .with_location("https://pkgs.k8s.io/core:/stable:/v1.29/deb/")
            .with_release("/")
        end
      end
    end
  end
end
