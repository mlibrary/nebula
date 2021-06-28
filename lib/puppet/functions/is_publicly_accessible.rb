# frozen_string_literal: true

# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

require 'ipaddr'

Puppet::Functions.create_function(:is_publicly_accessible) do
  dispatch :run do
    return_type 'Boolean'
  end

  def run
    ip_addresses.any? { |ip| public? ip }
  end

  def ip_addresses
    interfaces.values.map { |v| v['ip'] }.delete_if { |ip| ip.nil? }
  end

  def interfaces
    @interfaces ||= closure_scope['facts']['networking']['interfaces']
    @interfaces ||= {}
  end

  def public?(address)
    private_blocks.none? { |block| block.include? address }
  end

  def private_blocks
    @private_blocks ||= call_function('lookup',
                                      'umich::networks::private_blocks')
                        .map { |cidr| IPAddr.new(cidr) }
  end
end
