# frozen_string_literal: true

require "bundler"

require "voxpupuli/test/rake/puppetlint"
require "voxpupuli/test/rake/puppetsyntax"
require "voxpupuli/test/rake/spec"
require "voxpupuli/test/rake/validate"

desc "Run all tests [DEFAULT TASK]"
task test: %i[validate lint fixtures:prep ci:spec]
task default: %i[test]

desc "librarian_clean, fixtures:clean"
task clean: %i[librarian_clean fixtures:clean]

desc "alias for fixtures:prep"
task prep: %i[fixtures:prep]
