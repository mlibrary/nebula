# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

Puppet::Functions.create_function(:lookup_role) do
  dispatch :run do
    return_type 'String'
  end

  def run
    clear_internals
    case hiera_role
    when 'nebula::role::aws::auto'
      ec2_tag_role
    else
      hiera_role
    end
  end

  def clear_internals
    @hiera_role = nil
    @ec2_tag_role = nil
  end

  def hiera_role
    @hiera_role ||= call_function('lookup', 'role')
  end

  def ec2_tag_role
    @ec2_tag_role ||= closure_scope['facts']['ec2_tag_role']
    @ec2_tag_role ||= hiera_role
  end
end
