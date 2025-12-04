require "json"

module Nebula
  # adapted from rspec-puppet-facts
  def self.metadata
    return @metadata if @metadata
    unless File.file? metadata_file
      fail StandardError, "Can't find metadata.json... dunno why"
    end
    content = File.read metadata_file
    @metadata = JSON.parse content
  end

  def self.metadata_file
    "metadata.json"
  end

  def self.supported_os
    return @supported_os if @supported_os
    if ENV.key?("SUPPORTED_OS") && !ENV["SUPPORTED_OS"].empty?
      if /^(?<os>\w+) (?<rel>\d+(?:\.\d+)?)$/ =~ ENV["SUPPORTED_OS"]
        [{"operatingsystem" => os, "operatingsystemrelease" => [rel]}]
      else
        raise "can't parse SUPPORTED_OS env var"
      end
    else
      metadata["operatingsystem_support"]
    end
  end
end
