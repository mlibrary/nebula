filegroups = {
  "all_roles" => "spec/classes/all_roles_*_spec.rb",
  "profiles" => "spec/classes/profile/**/*_spec.rb",
  "roles" => "spec/classes/role/**/*_spec.rb"
}

desc "Run parallel_rspec on given filegroup"
task :ci, [:filegroup] do |t, args|
  require "parallel_tests"

  raise "rake #{t}: filegroup required, for list of options, see: 'rake ci:matrix'" unless args.filegroup

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
    raise "unrecognized filegroup, for list of options, see: 'rake ci:matrix'"
  end

  parallel_test_args = %w[--type rspec --verbose-process-command --verbose-rerun-command --serialize-stdout]
  ParallelTests::CLI.new.run([parallel_test_args, files].flatten)
end

namespace "ci" do
  desc "List CI matrix options"
  task :matrix do
    require "json"
    require_relative "../spec/spec_helper/supported_os"
    os_list = []
    Nebula.supported_os.each do |os|
      name = os["operatingsystem"]
      os["operatingsystemrelease"].each do |rel|
        os_list.push("#{name} #{rel}")
      end
    end

    puts "filegroup=#{filegroups.keys.concat(["classes"]).sort.to_json}"
    puts "os=#{os_list.to_json}"
  end
end
