require "yaml"
require "net/http"
require "uri"
require "json"

def metadata
  "nebula_metadata.yaml"
end

def next_maj(version)
  /^(?<maj>\d+)\.(?<_>\d+)\.(?<_>\d+)$/ =~ version or
    raise "can't parse version: #{version}"
  "#{maj.to_i + 1}.0.0"
end

meta = YAML.load_file(metadata)
deps = meta["dependencies"]
meta["dependencies"] = []

# validate
module_names = deps.map { |x| x["name"].split("/")[-1] }
module_names.length == module_names.uniq.length or
  raise "#{metadata} contains duplicate dependency"

fixtures = {}

deps.each do |mod|
  full_name = mod["name"]
  /^(?<_>(?<org_name>\w+)\/)?(?<mod_name>\w+)$/ =~ full_name or
    raise "#{full_name} is not a valid module name"

  if org_name
    # module from forge
    mod["repo"] and
      raise "field 'repo' makes no sense for modules installed from forge"
    mod["ref"] and
      raise "field 'ref' makes no sense for modules installed from forge"

    # get module metadata from forge
    uri = URI.parse "https://forgeapi.puppet.com/v3/modules/#{org_name}-#{mod_name}"
    resp = Net::HTTP.get_response(uri)
    resp.code == "200" or
      raise "failed to fetch metadata from for apt for module #{full_name}"

    forge_meta = JSON.parse(resp.body)
    current_version = forge_meta["current_release"]["version"]
    version_requirement = ">= #{current_version} < #{next_maj(current_version)}"

    if mod["version_requirement"]
      puts "WARNING: Fixed version requirement set for module #{full_name}!"
      puts "         I don't know how to handle this yet, so you'll need to add it to"
      puts "         metadata.json and .fixtures.yml manually!"
      puts
      puts "     #{mod["version_requirement"]}"
      puts
    end

    meta["dependencies"].push({"name" => full_name, "version_requirement" => version_requirement})
    fixtures["forge_modules"] ||= {}
    fixtures["forge_modules"][mod_name] = {"repo" => full_name, "ref" => current_version}
  else
    # module from git
    mod["repo"] or
      raise "field 'repo' required for modules installed from git"
    mod["version_requirement"] and
      raise "field 'version_requirement' makes no sense for modules installed from git"

    fixtures["repositories"] ||= []
    fixtures["repositories"][full_name] = {"repo" => mod["repo"]}
    mod["ref"] and
      fixtures["repositories"][full_name]["ref"] = mod["ref"]
  end
end

File.write(".fixtures.yml", {"fixtures" => fixtures}.to_yaml)
File.write("metadata.json", JSON.pretty_generate(meta) + "\n")
