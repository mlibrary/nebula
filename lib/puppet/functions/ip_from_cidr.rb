# frozen_string_literal: true

# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'ipaddr'

Puppet::Functions.create_function(:ip_from_cidr) do
  dispatch :run do
    required_param 'String',  :cidr
    required_param 'Integer', :index
    return_type 'String'
  end

  def run(cidr, index)
    base = IPAddr.new(cidr)
    result = IPAddr.new(base.to_i + index, base.family)
    raise(ArgumentError, "#{index} too large to fit in #{cidr}") unless base.include? result
    result.to_s
  end
end
