# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

Puppet::Functions.create_function(:nodes_for_class) do
  dispatch :nodes_for_class do
    required_param 'String', :class
    return_type 'Array[String]'
  end

  def nodes_for_class(class_title)
    call_function('puppetdb_query',
                  ['from', 'resources',
                   ['extract', ['certname'],
                    ['=', 'title', capitalize_each_namespace(class_title)]]])
      .map { |resource| resource['certname'] }.sort
  end

  private

  def capitalize_each_namespace(resource_name)
    resource_name.split('::').map { |ns| ns.capitalize }.join('::')
  end
end
