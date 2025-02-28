# frozen_string_literal: true

# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require "spec_helper"

describe "generate_mac" do
  it "generates simple addresses" do
    is_expected.to run.with_params("02:00:00", "example.com").and_return("02:00:00:a3:79:a6")
    is_expected.to run.with_params("12-0f-00", "example.com", 2).and_return("12:0f:00:a3:79:a4")
  end
  it "fails on invalid chars" do
    is_expected.to run.with_params("g2:00:00", "example.com", 0).and_raise_error(ArgumentError)
  end
  it "correctly masks final 3 bits" do
    is_expected.to run.with_params("06 12 34", "my.host.name", 0).and_return("06:12:34:3b:d9:9a")
    is_expected.to run.with_params("5a.67.89", "my.host.name", 3).and_return("5a:67:89:3b:d9:99")
    is_expected.to run.with_params("AE:BC:DE", "my.host.name", 7).and_return("ae:bc:de:3b:d9:9d")
  end
  it "fails on non-private oui" do
    is_expected.to run.with_params("03:00:00", "example.com", 0).and_raise_error(ArgumentError)
  end
  it "fails on out of range index" do
    is_expected.to run.with_params("02:00:00", "example.com", 11).and_raise_error(ArgumentError)
    is_expected.to run.with_params("02:00:00", "example.com", -1).and_raise_error(ArgumentError)
  end
end
