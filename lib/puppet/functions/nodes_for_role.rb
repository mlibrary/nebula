# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

Puppet::Functions.create_function(:nodes_for_role) do
  dispatch :nodes_for_role do
    required_param 'String', :role
    return_type 'Array[String]'
  end

  def nodes_for_role(role)
    call_function('puppetdb_query',
                  ['from', 'resources',
                   ['extract', ['certname'],
                    ['=', 'title', capitalize_each_namespace(role)]]])
      .map { |resource| resource['certname'] }
  end

  private

  def capitalize_each_namespace(resource_name)
    resource_name.split('::').map { |ns| ns.capitalize }.join('::')
  end
end
