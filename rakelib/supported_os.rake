desc "List supported operating systems"
task :supported_os do |t|
  require "json"
  require_relative "../spec/spec_helper/supported_os"

  list = []

  Nebula.supported_os.each do |os|
    name = os["operatingsystem"]
    os["operatingsystemrelease"].each do |rel|
      list.push("#{name} #{rel}")
    end
  end

  puts list.to_json
end
