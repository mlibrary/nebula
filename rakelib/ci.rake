# when adding a group here it MUST also be added to .github/workflows/ci.yml
filegroups = {
  "all_roles" => "spec/classes/all_roles_*_spec.rb",
  "profiles" => "spec/classes/profile/**/*_spec.rb",
  "roles" => "spec/classes/role/**/*_spec.rb"
}

desc "Run parallel_rspec on given filegroup"
task :ci, [:filegroup] do |t, args|
  require "parallel_tests"

  raise "rake #{t}: filegroup required, try 'rake ci:help'" unless args.filegroup

  if args.filegroup == "classes"
    # "classes" tests everything __except__ the globs in filegroups
    # default pattern from puppetlabs_spec_helper/rake_tasks.rb
    files = Rake::FileList["spec/{aliases,classes,defines,functions,hosts,integration,plans,tasks,type_aliases,types,unit}/**/*_spec.rb"]
    filegroups.each do |_, v|
      files -= Rake::FileList[v]
    end
  elsif filegroups.key?(args.filegroup)
    files = Rake::FileList[filegroups[args.filegroup]]
  else
    raise "unrecognized filegroup, try 'rake ci:help'"
  end

  parallel_test_args = %w[--type rspec --verbose-process-command --verbose-rerun-command --serialize-stdout]
  ParallelTests::CLI.new.run([parallel_test_args, files].flatten)
end

namespace "ci" do
  task :help do
    puts "rake 'ci[filegroup]'"
    puts "\tfilegroup must be one of: \"#{filegroups.keys.join("\", \"")}\", or \"classes\""
    puts "\t(\"classes\" runs all tests not in any of the other groups)"
  end
end
