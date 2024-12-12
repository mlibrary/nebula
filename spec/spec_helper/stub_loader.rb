# frozen_string_literal: true

# Stub the default dependency loader to do normal resolution except where overridden
def stub_loader!
  allow_any_instance_of(Puppet::Pops::Loader::DependencyLoader).to receive(:load).and_call_original
end

# Stub the dependency loader to resolve a named function to a double of some type
#
# @param name [String] The name of the puppet function to stub
# @param dbl [RSpec double] Optional RSpec double with `call` mocked;
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

def stub(name)
  dbl = double(name)

  yield dbl
  stub_function(name, dbl)
end

def allow_call(dbl)
  allow(dbl).to receive(:call)
end
