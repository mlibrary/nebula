# frozen_string_literal: true

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

    value = run_query(node_id, fact_keys.shift)

    if fact_keys.empty?
      value
    else
      value.dig(*fact_keys)
    end
  end

  private

  def run_query(node_id, fact_name)
    call_function('puppetdb_query',
                  ['from', 'facts',
                   ['extract', ['value'],
                    ['and',
                     ['=', 'certname', node_id],
                     ['=', 'name', fact_name]]]])[0]['value']
  end
end
