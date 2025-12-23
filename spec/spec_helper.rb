# frozen_string_literal: true

# TODO: replace this file with voxpupuli spec_helper.rb
#       This will require:
#         - removing default_facts, or porting the logic to our own spec_helper
#         - move spec_helper/* and spec_helper_local.rb to /spec/support/spec/

RSpec.configure do |c|
  c.mock_with :rspec
end

require 'voxpupuli/test/spec_helper'
require 'rspec-puppet-facts'

require 'spec_helper_local' if File.file?(File.join(File.dirname(__FILE__), 'spec_helper_local.rb'))

include RspecPuppetFacts

default_facts = {
  puppetversion: Puppet.version,
  facterversion: Facter.version,
}

default_fact_files = [
  File.expand_path(File.join(File.dirname(__FILE__), 'default_facts.yml')),
  File.expand_path(File.join(File.dirname(__FILE__), 'default_module_facts.yml')),
]

default_fact_files.each do |f|
  next unless File.exist?(f) && File.readable?(f) && File.size?(f)

  begin
    default_facts.merge!(YAML.safe_load(File.read(f), permitted_classes: [], permitted_symbols: [], aliases: true))
  rescue StandardError => e
    RSpec.configuration.reporter.message "WARNING: Unable to load #{f}: #{e}"
  end
end

# read default_facts and merge them over what is provided by facterdb
default_facts.each do |fact, value|
  add_custom_fact fact, value
end

RSpec.configure do |c|
  c.default_facts = default_facts
  c.before :each do
    # set to strictest setting for testing
    # by default Puppet runs at warning level
    Puppet.settings[:strict] = :warning
    Puppet.settings[:strict_variables] = true
  end

  c.after(:suite) do
    RSpec::Puppet::Coverage.report!(0)
  end

  # Filter backtrace noise
  backtrace_exclusion_patterns = [
    %r{spec_helper},
    %r{gems},
  ]

  if c.respond_to?(:backtrace_exclusion_patterns)
    c.backtrace_exclusion_patterns = backtrace_exclusion_patterns
  elsif c.respond_to?(:backtrace_clean_patterns)
    c.backtrace_clean_patterns = backtrace_exclusion_patterns
  end
end

# 'spec_overrides' from sync.yml will appear below this line
module DefaultHieraConfig
  extend RSpec::SharedContext
  let(:hiera_config) { 'spec/fixtures/hiera/default_config.yaml' }
end

RSpec.configure do |c|
  c.default_facts = default_facts
  c.include DefaultHieraConfig
end 
