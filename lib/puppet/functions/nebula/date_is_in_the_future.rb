# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::date_is_in_the_future
#
# Return true if the given date is in the future.
#
# @param date Date to check
#
# @example Check a date in the past
#   nebula::date_is_in_the_future('1970-01-01') => false
Puppet::Functions.create_function(:'nebula::date_is_in_the_future') do
  dispatch :run do
    required_param 'String', :date
    return_type 'Boolean'
  end

  def run(date)
    Date.strptime(date, '%Y-%m-%d') > Date.today
  end
end
