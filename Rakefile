# frozen_string_literal: true

require 'bundler'
require 'puppet_litmus/rake_tasks' if Gem.loaded_specs.key? 'puppet_litmus'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-syntax/tasks/puppet-syntax'
require 'puppet-strings/tasks' if Gem.loaded_specs.key? 'puppet-strings'

# override puppetlabs_spec_helper's defaults
PuppetLint.configuration.ignore_paths << 'modules/**/*.pp'
PuppetLint.configuration.send('disable_relative')
PuppetLint.configuration.send('disable_puppet_url_without_modules')
PuppetLint.configuration.send('disable_strict_indent')
PuppetLint.configuration.send('disable_trailing_comma')
