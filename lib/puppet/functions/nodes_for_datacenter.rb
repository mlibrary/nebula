# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

Puppet::Functions.create_function(:nodes_for_datacenter) do
  dispatch :nodes_for_datacenter do
    required_param 'String', :datacenter
    return_type 'Array[String]'
  end

  def nodes_for_datacenter(datacenter)
    call_function('puppetdb_query',
                  ['from', 'facts',
                   ['extract', ['certname'],
                    ['and',
                     ['=', 'name', 'datacenter'],
                     ['=', 'value', datacenter]]]])
      .map { |fact| fact['certname'] }
  end
end
