source 'https://rubygems.org'

minor_version = Gem::Version.new(RUBY_VERSION.dup).segments[0..1].join('.')

gem 'rake', '>= 12.3.3'

group :development do
  gem "fast_gettext",                                  require: false
  gem "puppet-module-posix-default-r#{minor_version}", require: false, platforms: [:ruby]
  gem "puppet-module-posix-dev-r#{minor_version}",     require: false, platforms: [:ruby]
  gem "rspec-puppet-utils"
  gem "faker"
  gem "parallel_tests"
end

gem 'puppet', '~> 6.19'
gem 'puppet-strings'
gem 'semantic_puppet'
gem 'yard', '>= 0.9.20'

# Evaluate Gemfile.local and ~/.gemfile if they exist
[
  "#{__FILE__}.local",
  File.join(Dir.home, '.gemfile'),
].each do |gemfile|
  if File.file?(gemfile) && File.readable?(gemfile)
    eval(File.read(gemfile), binding)
  end
end

