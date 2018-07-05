# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

Puppet::Functions.create_function(:find_all_files_under) do
  dispatch :find_all_files_under do
    required_param 'String', :path
    return_type 'Array[String]'
  end

  def find_all_files_under(path)
    if File.directory? path
      all_files_under_dir(path).sort

    elsif File.exist? path
      [path]

    else
      []
    end
  end

  private

  def all_files_under_dir(base)
    Dir.foreach(base).reject { |f| %w[. ..].include? f }.map { |filename|
      find_all_files_under("#{base}/#{filename}")
    }.flatten
  end
end
