# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

Puppet::Functions.create_function(:fact_for) do
  dispatch :fact_for do
    required_param 'String', :node_id
    required_param 'String', :fact_name
  end

  def fact_for(node_id, fact_name)
    fact_keys = fact_name.split('.')
    fact_base = fact_keys.shift

    value = call_function('puppetdb_query',
                          ['from', 'facts',
                           ['extract', ['value'],
                            ['and',
                             ['=', 'certname', node_id],
                             ['=', 'name', fact_base]]]])[0]['value']

    fact_keys.each do |key|
      value = value[key]
    end

    value
  end
end
