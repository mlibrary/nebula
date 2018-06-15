# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

Puppet::Functions.create_function(:nodes_for_role) do
  dispatch :nodes_for_role do
    required_param 'String', :role
    return_type 'Array[String]'
  end

  def nodes_for_role(role)
    db_role = role.split('::').map { |x| x.capitalize }.join('::')

    call_function('puppetdb_query',
                  ['from', 'resources',
                   ['extract', ['certname'],
                    ['=', 'title', db_role]]]).map { |x| x['certname'] }
  end
end
