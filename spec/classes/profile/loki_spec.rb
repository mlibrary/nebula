# frozen_string_literal: true

require 'spec_helper'

describe 'nebula::profile::loki' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_apt__source('grafana') }
      it { is_expected.to contain_package('alloy') }
      it { is_expected.to contain_service('alloy') }

      it { is_expected.to contain_file('/var/lib/alloy/crt.pem') }
      it { is_expected.to contain_file('/var/lib/alloy/crt.key').with_mode('0600').with_owner('alloy') }

      it "writes /etc/default/alloy to set up /etc/alloy/ as a drop-in config dir" do
        is_expected.to contain_file('/etc/default/alloy')
          .with_content(%r|CONFIG_FILE="/etc/alloy/"|)
          .with_content(%r|managed by Puppet|)
      end

      it "writes grafana alloy config" do
        is_expected.to contain_file('/etc/alloy/config.alloy')
          .with_content(/managed by Puppet/)
          .with_content(/stage.static_labels {values = {"hostname" = "/)
          .with_content(%r|url = "https://loki-gateway.loki/loki/api/v1/push"|)
      end

      context("with loki url set") do
        let(:params) { {endpoint_url: "https://loki.example.com/loki/api/v1/push"} }
        it "writes loki url to config.alloy" do
          is_expected.to contain_file('/etc/alloy/config.alloy')
            .with_content(%r|url = "https://loki.example.com/loki/api/v1/push"|)
        end
      end

    end
  end
end
