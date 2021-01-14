# Attempt to load voxupuli-test (which pulls in puppetlabs_spec_helper),
# otherwise attempt to load it directly.
begin
  require 'voxpupuli/test/rake'
rescue LoadError
  require 'puppetlabs_spec_helper/rake_tasks'
end

PuppetLint.configuration.send('disable_file_ensure')
PuppetLint.configuration.send('disable_leading_zero')
PuppetLint.configuration.send('disable_legacy_facts')
PuppetLint.configuration.send('disable_manifest_whitespace_arrows_single_space_after')
PuppetLint.configuration.send('disable_manifest_whitespace_class_name_single_space_after')
PuppetLint.configuration.send('disable_manifest_whitespace_closing_brace_after')
PuppetLint.configuration.send('disable_manifest_whitespace_closing_brace_before')
PuppetLint.configuration.send('disable_manifest_whitespace_closing_bracket_after')
PuppetLint.configuration.send('disable_manifest_whitespace_closing_bracket_before')
PuppetLint.configuration.send('disable_manifest_whitespace_double_newline_end_of_file')
PuppetLint.configuration.send('disable_manifest_whitespace_newline_beginning_of_file')
PuppetLint.configuration.send('disable_manifest_whitespace_opening_brace_after')
PuppetLint.configuration.send('disable_manifest_whitespace_opening_brace_before')
PuppetLint.configuration.send('disable_manifest_whitespace_opening_bracket_after')
PuppetLint.configuration.send('disable_manifest_whitespace_opening_bracket_before')
PuppetLint.configuration.send('disable_manifest_whitespace_two_empty_lines')
PuppetLint.configuration.send('disable_relative_classname_inclusion')
PuppetLint.configuration.send('disable_resource_reference_with_unquoted_title')
PuppetLint.configuration.send('disable_strict_indent')
PuppetLint.configuration.send('disable_trailing_comma')

# load optional tasks for releases
# only available if gem group releases is installed
begin
  require 'voxpupuli/release/rake_tasks'
rescue LoadError
end

desc "Run main 'test' task and report merged results to coveralls"
task test_with_coveralls: [:test] do
  if Dir.exist?(File.expand_path('../lib', __FILE__))
    require 'coveralls/rake/task'
    Coveralls::RakeTask.new
    Rake::Task['coveralls:push'].invoke
  else
    puts 'Skipping reporting to coveralls.  Module has no lib dir'
  end
end

desc 'Generate REFERENCE.md'
task :reference, [:debug, :backtrace] do |t, args|
  patterns = ''
  Rake::Task['strings:generate:reference'].invoke(patterns, args[:debug], args[:backtrace])
end

begin
  require 'github_changelog_generator/task'
  require 'puppet_blacksmith'
  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    version = (Blacksmith::Modulefile.new).version
    config.future_release = "v#{version}" if version =~ /^\d+\.\d+.\d+$/
    config.header = "# Changelog\n\nAll notable changes to this project will be documented in this file.\nEach new release typically also includes the latest modulesync defaults.\nThese should not affect the functionality of the module."
    config.exclude_labels = %w{duplicate question invalid wontfix wont-fix modulesync skip-changelog}
    config.user = 'voxpupuli'
    metadata_json = File.join(File.dirname(__FILE__), 'metadata.json')
    metadata = JSON.load(File.read(metadata_json))
    config.project = metadata['name']
  end

  # Workaround for https://github.com/github-changelog-generator/github-changelog-generator/issues/715
  require 'rbconfig'
  if RbConfig::CONFIG['host_os'] =~ /linux/
    task :changelog do
      puts 'Fixing line endings...'
      changelog_file = File.join(__dir__, 'CHANGELOG.md')
      changelog_txt = File.read(changelog_file)
      new_contents = changelog_txt.gsub(%r{\r\n}, "\n")
      File.open(changelog_file, "w") {|file| file.puts new_contents }
    end
  end

rescue LoadError
end
# vim: syntax=ruby
