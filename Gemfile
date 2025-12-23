source ENV['GEM_SOURCE'] || 'https://rubygems.org'

group :test do
  gem 'voxpupuli-test', '~> 13.0',  :require => false
  gem 'puppet_metadata', '~> 5.0',  :require => false
  gem 'standard',                   :require => false
  gem 'faker',                      :require => false
  gem 'librarian-puppet', '>= 5.0', :require => false
end

gem 'rake', :require => false
gem 'net-ftp' # required by puppetlabs/apt

gem 'openvox', ENV.fetch('OPENVOX_GEM_VERSION', [">= 7", "< 9"]), :require => false, :groups => [:test]

# vim: syntax=ruby
