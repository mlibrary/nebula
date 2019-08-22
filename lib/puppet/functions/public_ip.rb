# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

Puppet::Functions.create_function(:public_ip) do
  dispatch :run do
    return_type 'String'
  end

  def run
    if aws_node?
      ec2_metadata['public_ipv4']
    else
      ipaddress
    end
  end

  def aws_node?
    datacenter.start_with?('aws-') && ec2_metadata.key?('public_ipv4')
  end

  def datacenter
    facts['datacenter']
  end

  def facts
    closure_scope['facts']
  end

  def ec2_metadata
    if facts.key? 'ec2_metadata'
      facts['ec2_metadata']
    else
      {}
    end
  end

  def ipaddress
    facts['ipaddress']
  end
end
