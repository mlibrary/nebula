source 'https://rubygems.org'

minor_version = Gem::Version.new(RUBY_VERSION.dup).segments[0..1].join('.')

group :development do
  gem "fast_gettext",                                  require: false
  gem "puppet-module-posix-default-r#{minor_version}", require: false, platforms: [:ruby]
  gem "puppet-module-posix-dev-r#{minor_version}",     require: false, platforms: [:ruby]
  gem "rspec-puppet-utils"
end

gem 'puppet'
gem 'puppet-strings'
gem 'semantic_puppet'

# Evaluate Gemfile.local and ~/.gemfile if they exist
[
  "#{__FILE__}.local",
  File.join(Dir.home, '.gemfile'),
].each do |gemfile|
  if File.file?(gemfile) && File.readable?(gemfile)
    eval(File.read(gemfile), binding)
  end
end

