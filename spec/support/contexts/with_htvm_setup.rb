# frozen_string_literal: true

require_relative "./with_mocked_nodes"
require "faker"

RSpec.shared_context "with setup for htvm node" do |os_facts|
  let(:facts) do
    os_facts.deep_merge(
      datacenter: "somedc",
      networking: {"ip" => Faker::Internet.ip_v4_address, "interfaces" => {}, "hostname" => "thisnode"}
    )
  end
  let(:hiera_config) { "spec/fixtures/hiera/hathitrust_config.yaml" }
  let(:rolenode) { {"ip" => Faker::Internet.ip_v4_address, "hostname" => "rolenode"} }

  include_context "with mocked puppetdb functions", "somedc", %w[rolenode], "nebula::profile::haproxy" => %w[]
end
