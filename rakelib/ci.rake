def all_spec_files
  # default pattern from puppetlabs_spec_helper/rake_tasks.rb
  Rake::FileList["spec/{aliases,classes,defines,functions,hosts,integration,plans,tasks,type_aliases,types,unit}/**/*_spec.rb"]
end

def profile_spec_files
  Rake::FileList["spec/classes/profile/**/*_spec.rb"]
end

def parallel_test_args
  %w[--type rspec --verbose-process-command --verbose-rerun-command --serialize-stdout]
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

  desc "Run parallel spec only on profile specs"
  task :spec_profiles do |t|
    require "parallel_tests"

    ParallelTests::CLI.new.run([parallel_test_args, profile_spec_files].flatten)
  end

  desc "Run parallel spec on all specs except profiles"
  task :spec_classes do |t|
    require "parallel_tests"

    files = all_spec_files - profile_spec_files
    ParallelTests::CLI.new.run([parallel_test_args, files].flatten)
  end
end
