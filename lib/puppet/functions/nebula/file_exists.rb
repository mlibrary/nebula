# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::file_exists
#
# Return true if the given file exists on the puppet master.
#
# @param path_to_file Path to the file whose existance we're to test
#
# @example Create a file only if its source file exists
#   if nebula::file_exists('/my/source/file') {
#     file { '/agent/path/for/file':
#       source => 'file:///my/source/file',
#     }
#   } else {
#     notify { "couldn't create /agent/path/for/file": }
#   }
Puppet::Functions.create_function(:'nebula::file_exists') do
  dispatch :run do
    required_param 'String', :path_to_file
    return_type 'Boolean'
  end

  def run(path_to_file)
    File.exist? path_to_file
  end
end
