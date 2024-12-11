# Copied from https://github.com/Accuity/rspec-puppet-utils

# The MIT License (MIT)
# Copyright © 2017 Accuity Inc.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the “Software”), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'puppet'
require 'mocha/api'

module RSpec::Puppet
  module Support
    def self.clear_cache
      begin
        # Cache is a separate class since rspec-puppet 2.3.0
        require 'rspec-puppet/cache'
        @@cache = RSpec::Puppet::Cache.new
      rescue Gem::LoadError
        @@cache = {}
      end
    end
  end
end

module RSpecPuppetUtils

  class MockFunction

    def initialize(name, options = {})
      parse_options! options
      this = self
      Puppet::Parser::Functions.newfunction(name.to_sym, options) { |args| this.call args }
      yield self if block_given?
    end

    def call(args)
      execute *args
    end

    def execute(*args)
      args
    end

    def stubbed
      self.stubs(:execute)
    end

    def expected(*args)
      RSpec::Puppet::Support.clear_cache unless args.include? :keep_cache
      self.expects(:execute)
    end

    private

    def parse_options!(options)
      unless options[:type]
        options[:type] = :rvalue
      end
      unless [:rvalue, :statement].include? options[:type]
        raise ArgumentError, "Type should be :rvalue or :statement, not #{options[:type]}"
      end
      unless options[:arity].nil? || options[:arity].is_a?(Integer)
        raise ArgumentError, 'arity should be an integer'
      end
    end

  end

end
