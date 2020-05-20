# frozen_string_literal: true

# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'ip_from_cidr' do
  [
    ['10.0.0.0/8', 0, '10.0.0.0'],
    ['10.0.0.0/8', 1, '10.0.0.1'],
    ['10.0.0.0/8', 123, '10.0.0.123'],
    ['10.0.0.0/8', 256, '10.0.1.0'],
    ['192.168.14.0/24', 55, '192.168.14.55'],
    ['fc00::/7', 0x123456789abcdef, 'fc00::123:4567:89ab:cdef'],
  ].each do |cidr, i, ipaddress|
    it { is_expected.to run.with_params(cidr, i).and_return(ipaddress) }
  end

  it { is_expected.to run.with_params('10.0.0.0/24', 256).and_raise_error(ArgumentError) }
end
