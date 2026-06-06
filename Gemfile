source ENV['GEM_SOURCE'] || 'https://rubygems.org'

group :test do
  gem 'puppet_metadata', '~> 6.1',  :require => false
  gem 'standard',                   :require => false
  gem 'faker',                      :require => false
  gem 'librarian-puppet', '>= 5.0', :require => false
  git "https://github.com/mlibrary/voxpupuli-test.git", tag: "v14.0.0-5" do
    gem "voxpupuli-test",           :require => false
  end
end

gem 'rake', :require => false
gem 'net-ftp' # required by puppetlabs/apt

gem 'openvox', ENV.fetch('OPENVOX_GEM_VERSION', [">= 7", "< 9"]), :require => false, :groups => [:test]

# vim: syntax=ruby
