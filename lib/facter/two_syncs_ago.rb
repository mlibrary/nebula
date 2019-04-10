# frozen_string_literal: true

require 'yaml'

# This will put the contents of puppet's summary of its last run into a
# facter fact. It does no analysis: it only reads the yaml and takes the
# object.
#
# The intended use is that the fact will be stored in puppetdb, which
# will give us an easy way to query puppetdb to find nodes that have not
# recently synced with the puppet master (or ones that recently had some
# sort of error).
#
# This is not intended to be used for archaeology -- it's not detailed
# enough to give much help as to why anything broke. Its intended
# purpose is only for quick and simple error detection.
Facter.add(:two_syncs_ago_summary) do
  setcode do
    summary_file_path = '/opt/puppetlabs/puppet/cache/state/last_run_summary.yaml'

    if File.exist? summary_file_path
      YAML.load_file(summary_file_path)
    else
      {}
    end
  end
end
