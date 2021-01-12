# frozen_string_literal: true

# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'ipaddr'

Puppet::Functions.create_function(:pick_network_interface_for_ip) do
  dispatch :run do
    required_param 'Stdlib::IP::Address', :ip_address
    return_type 'String'
  end

  def run(ip_address)
    # Each is of the form [prefix, interface_name], so we sort by prefix
    # and choose the most tightly-bound interface available (which will
    # have the largest prefix).
    prefixes_interfaces(ip_address).sort.last[1]
  end

  def prefixes_interfaces(ip_address)
    [].tap do |possible_interfaces|
      interfaces.each do |name, interface|
        if cidr(interface).include? ip_address
          possible_interfaces << [cidr(interface).prefix, name]
        end
      end
    end
  end

  def interfaces
    facts['networking']['interfaces']
  end

  def facts
    closure_scope['facts']
  end

  def cidr(interface)
    if interface.has_key?('network') && interface.has_key?('netmask')
      IPAddr.new("#{interface['network']}/#{interface['netmask']}")
    else
      IPAddr.new('0.0.0.0/32')
    end
  end
end
