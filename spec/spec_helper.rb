# frozen_string_literal: true

RSpec.configure do |c|
  c.mock_with :rspec
  c.example_status_persistence_file_path = 'spec/examples.txt'
end

require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-utils'
require 'rspec-puppet-facts'
include RspecPuppetFacts

require 'spec_helper_local' if File.file?(File.join(File.dirname(__FILE__), 'spec_helper_local.rb'))

default_facts = {
  puppetversion: Puppet.version,
  facterversion: Facter.version,
}

# The os.architecture fact was not being populated, though the rest of the os hash is.
# This will promote the os.architecture value to the top level if it is set, otherwise
# push the top level down, if it is set, otherwise set both to amd64.
# We do not anticipate a case where these should remain different values in a test context.
add_custom_fact :architecture, ->(_os, facts) { facts[:os][:architecture] ||= (facts[:architecture] || 'amd64') }

default_facts_path = File.expand_path(File.join(File.dirname(__FILE__), 'default_facts.yml'))
default_module_facts_path = File.expand_path(File.join(File.dirname(__FILE__), 'default_module_facts.yml'))

if File.exist?(default_facts_path) && File.readable?(default_facts_path)
  default_facts.merge!(YAML.safe_load(File.read(default_facts_path)))
end

if File.exist?(default_module_facts_path) && File.readable?(default_module_facts_path)
  default_facts.merge!(YAML.safe_load(File.read(default_module_facts_path)))
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
