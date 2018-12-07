# frozen_string_literal: true

RSpec.configure do |c|
  c.mock_with :rspec
end

require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-utils'
require 'rspec-puppet-facts'
require 'faker'
include RspecPuppetFacts

default_facts = {
  puppetversion: Puppet.version,
  facterversion: Facter.version,
}

default_facts_path = File.expand_path(File.join(File.dirname(__FILE__), 'default_facts.yml'))
default_module_facts_path = File.expand_path(File.join(File.dirname(__FILE__), 'default_module_facts.yml'))

if File.exist?(default_facts_path) && File.readable?(default_facts_path)
  default_facts.merge!(YAML.safe_load(File.read(default_facts_path)))
end

if File.exist?(default_module_facts_path) && File.readable?(default_module_facts_path)
  default_facts.merge!(YAML.safe_load(File.read(default_module_facts_path)))
end

module DefaultHieraConfig
  extend RSpec::SharedContext
  let(:hiera_config) { 'spec/fixtures/hiera/default_config.yaml' }
end

RSpec.configure do |c|
  c.default_facts = default_facts
  c.include DefaultHieraConfig
end

# Stub the default dependency loader to do normal resolution except where overridden
def stub_loader!
  allow_any_instance_of(Puppet::Pops::Loader::DependencyLoader).to receive(:load).and_call_original
end

# Stub the dependency loader to resolve a named function to a double of some type
#
# @param name [String] The name of the puppet function to stub
# @param dbl [RSpec double] Optional RSpeck double with `call` mocked;
#        will be used instead of the block if supplied
# @yield [*args] A block that takes all parameters given to the puppet function;
#        required if dbl is not supplied, and ignored if dbl is supplied
def stub_function(name, dbl = nil, &func)
  func = dbl || func
  stub = ->(_scope, *args, &block) do
    func.call(*args, &block)
  end
  allow_any_instance_of(Puppet::Pops::Loader::DependencyLoader).to receive(:load).with(:function, name).and_return(stub)
end

def stub_with_call(name)
  double(name).tap do |dbl|
    dbl.define_singleton_method(:allow_call) do
      allow(dbl).to receive(:call)
    end
    stub_function(name, dbl)
  end
end

def stub(name)
  dbl = double(name)

  yield dbl
  stub_function(name, dbl)
end

def allow_call(dbl)
  allow(dbl).to receive(:call)
end
