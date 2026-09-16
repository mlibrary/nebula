def all_spec_files
  # default pattern from puppetlabs_spec_helper/rake_tasks.rb
  Rake::FileList["spec/{aliases,classes,defines,functions,hosts,integration,plans,tasks,type_aliases,types,unit}/**/*_spec.rb"]
end

def parallel_test_args
  %w[--type rspec --verbose-process-command --verbose-rerun-command --serialize-stdout]
end

# Warning: False negatives guaranteed. Running these specs is NOT a
# substitute for running all specs, but this is pretty good.
def changed_spec_heuristic
  changed = `git diff --name-only --diff-filter=d origin/production..`.lines(chomp: true)

  # get changed .pp files, __try__ to get the associated spec files
  pp_specs = changed.grep(/\.pp$/).filter_map do |path|
    klass = path.sub(/^manifests\//, "nebula::").gsub("/", "::").sub(/\.pp$/, "")
    matches = all_spec_files.select { |f| File.read(f).include?(%(describe "#{klass}")) }
    warn "WARNING: no spec found for class '#{klass}'" if matches.empty?
    matches
  end.flatten

  # combine w/ changed spec files
  (pp_specs + changed.grep(/_spec\.rb$/)).to_set.to_a
end

namespace "ci" do
  desc "Run parallel spec w/ pretty serialized output"
  task :spec do |t|
    require "parallel_tests"

    ParallelTests::CLI.new.run([parallel_test_args, all_spec_files].flatten)
  end

  desc "List all spec files"
  task :files do |t|
    puts all_spec_files
  end
end

namespace :spec do
  desc "Run specs for changed manifests and spec files vs origin/production"
  task :changed do
    specs = changed_spec_heuristic
    if specs.length > 0
      ParallelTests::CLI.new.run([parallel_test_args, specs].flatten)
    else
      puts "No spec files to run."
    end
  end

  desc "List which specs have changed since origin/production"
  task :list_changed do
    puts changed_spec_heuristic
  end
end
