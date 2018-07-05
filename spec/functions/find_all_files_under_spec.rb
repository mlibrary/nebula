# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'find_all_files_under' do
  before :each do
    `mkdir spec/test_files`

    `mkdir spec/test_files/empty`

    `mkdir spec/test_files/one_file`
    `touch spec/test_files/one_file/just_me.txt`

    `mkdir spec/test_files/some_empty_subdirs`
    `mkdir spec/test_files/some_empty_subdirs/a`
    `mkdir spec/test_files/some_empty_subdirs/b`
    `mkdir spec/test_files/some_empty_subdirs/c`
    `mkdir spec/test_files/some_empty_subdirs/c/cc`

    `mkdir spec/test_files/nested_files`
    `mkdir spec/test_files/nested_files/a`
    `mkdir spec/test_files/nested_files/b`
    `mkdir spec/test_files/nested_files/b/c`
    `touch spec/test_files/nested_files/a_file.txt`
    `touch spec/test_files/nested_files/a/another_file.txt`
    `touch spec/test_files/nested_files/b/c/yet_another_file.txt`
  end

  after :each do
    `rm -r spec/test_files`
  end

  it { is_expected.to run.with_params('spec/test_files/does_not_exist').and_return([]) }

  it { is_expected.to run.with_params('spec/test_files/empty').and_return([]) }

  it { is_expected.to run.with_params('spec/test_files/one_file').and_return(%w[spec/test_files/one_file/just_me.txt]) }
  it { is_expected.to run.with_params('spec/test_files/one_file/just_me.txt').and_return(%w[spec/test_files/one_file/just_me.txt]) }

  it { is_expected.to run.with_params('spec/test_files/some_empty_subdirs').and_return([]) }

  it do
    is_expected.to run.with_params('spec/test_files/nested_files').and_return(
      %w[spec/test_files/nested_files/a_file.txt spec/test_files/nested_files/a/another_file.txt spec/test_files/nested_files/b/c/yet_another_file.txt].sort,
    )
  end
end
