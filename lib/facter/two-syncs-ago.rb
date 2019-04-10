# frozen_string_literal: true
require 'yaml'

Facter.add(:two_syncs_ago_summary) do
  setcode do
    if File.exist? '/opt/puppetlabs/puppet/cache/state/last_run_summary.yaml'
      File.open('/opt/puppetlabs/puppet/cache/state/last_run_summary.yaml', 'r') do |f|
        YAML.load(f.read)
      end
    else
      {}
    end
  end
end
