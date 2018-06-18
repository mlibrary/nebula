# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Return true if the given date is in the future.
Puppet::Functions.create_function(:'nebula::date_is_in_the_future') do
  # @param date Date to check
  # @return [Boolean] whether the given date is in the future
  #
  # @example Check a date in the past
  #   nebula::date_is_in_the_future('1970-01-01') => false
  dispatch :run do
    required_param 'String', :date
    return_type 'Boolean'
  end

  def run(date)
    Date.strptime(date, '%Y-%m-%d') > Date.today
  end
end
