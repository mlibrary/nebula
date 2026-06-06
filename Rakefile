# frozen_string_literal: true

require 'bundler'

require 'voxpupuli/test/rake/puppetlint'
require 'voxpupuli/test/rake/puppetsyntax'
require 'voxpupuli/test/rake/spec'
require 'voxpupuli/test/rake/validate'

task test: %i[lint validate standard fixtures:prep ci:spec]

task default: [:test]
