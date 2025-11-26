# when adding a group here it MUST also be added to .github/workflows/ci.yml
test_files = {
  "all_roles_1" => "spec/classes/all_roles_[1-4]_spec.rb",
  "all_roles_2" => "spec/classes/all_roles_[5-8]_spec.rb",
  "profiles_1" => "spec/classes/profile/{[a-h]*/**/*_spec.rb,[a-h]*_spec.rb}",
  "profiles_2" => "spec/classes/profile/{[^a-h]*/**/*_spec.rb,[^a-h]*_spec.rb}",
  "roles" => "spec/classes/role/**/*_spec.rb"
}

desc "Run parallel_rspec on given filegroup"
task :ci, [:filegroup] do |t, args|
  require "parallel_tests"

  raise "rake #{t}: filegroup required, try 'rake ci:help'" unless args.filegroup

  if args.filegroup == "classes"
    # "classes" tests everything __except__ the globs in test_files
    # default pattern from puppetlabs_spec_helper/rake_tasks.rb
    files = Rake::FileList["spec/{aliases,classes,defines,functions,hosts,integration,plans,tasks,type_aliases,types,unit}/**/*_spec.rb"]
    test_files.each do |_, v|
      files -= Rake::FileList[v]
    end
  elsif test_files.key?(args.filegroup)
    files = Rake::FileList[test_files[args.filegroup]]
  else
    raise "unrecognized filegroup, try 'rake ci:help'"
  end

  parallel_test_args = %w[--type rspec --verbose-process-command --verbose-rerun-command --serialize-stdout]
  ParallelTests::CLI.new.run([parallel_test_args, files].flatten)
end

namespace "ci" do
  task :help do
    puts "rake 'ci[filegroup]'"
    puts "\tfilegroup must be one of: \"#{test_files.keys.join("\", \"")}\", or \"classes\""
    puts "\t(\"classes\" runs all tests not in any of the other groups)"
  end
end
