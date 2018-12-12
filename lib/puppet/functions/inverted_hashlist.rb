# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

Puppet::Functions.create_function(:inverted_hashlist) do
  dispatch :from_lookup do
    required_param 'String', :lookup_string
    return_type 'Hash[String, Array[String]]'
  end

  dispatch :from_hash do
    required_param 'Hash[String, Array[String]]', :input_hash
    return_type 'Hash[String, Array[String]]'
  end

  def from_lookup(lookup_string)
    from_hash(call_function('lookup', lookup_string))
  end

  def from_hash(input_hash)
    Hash.new { |h, k| h[k] = [] }.tap do |result|
      input_hash.each do |key, values|
        values.each do |value|
          result[value] << key
        end
      end
    end
  end
end
