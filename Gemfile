source ENV["GEM_SOURCE"] || "https://rubygems.org"

group :test do
  gem "voxpupuli-test", git: "https://github.com/mlibrary/voxpupuli-test.git", tag: "v14.0.0-6", require: false
  gem "puppet_metadata", "~> 6.1", require: false
  gem "faker", require: false
  gem "librarian-puppet", ">= 5.0", require: false
end

gem "rake", require: false
gem "net-ftp" # required by puppetlabs/apt

gem "openvox", ENV.fetch("OPENVOX_GEM_VERSION", [">= 8", "< 9"]), require: false, groups: [:test]
