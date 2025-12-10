def all_spec_files
  # default pattern from puppetlabs_spec_helper/rake_tasks.rb
  Rake::FileList["spec/{aliases,classes,defines,functions,hosts,integration,plans,tasks,type_aliases,types,unit}/**/*_spec.rb"]
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
end
