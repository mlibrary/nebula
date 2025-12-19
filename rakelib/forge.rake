require "yaml"
require "net/http"
require "uri"
require "json"

def metadata_file
  "metadata.json"
end

def fixtures_file
  ".fixtures.yml"
end

def metadata_src_file
  "rakelib/metadata.yaml"
end

def api_server
  "forgeapi.puppet.com"
end

def forge_meta(forge_module)
  slug = forge_module.tr("/", "-")
  uri = URI.parse "https://#{api_server}/v3/modules/#{slug}"
  resp = Net::HTTP.get_response(uri)
  resp.code == "200" or
    raise "failed to fetch metadata from #{api_server} for module #{forge_module}"

  JSON.parse(resp.body)
end

namespace "forge" do
  desc "list outdated modules in .fixtures.yml"
  task :outdated do |t|
    fixtures = YAML.load_file(fixtures_file)
    fixtures["fixtures"]["forge_modules"].values.each do |mod|
      repo = mod["repo"]
      vers = mod["ref"]

      releases = forge_meta(mod["repo"])["releases"].map { |x| x["version"] }
      installed_index = releases.find_index(vers)
      installed = releases[installed_index]

      if installed_index != 0
        newer = releases.slice(0, installed_index).join(", ")
        puts "#{repo} (#{installed}) < #{newer}"
        puts "https://forge.puppet.com/modules/#{repo}"

        puts
      end
    end
  end

  def next_maj(version)
    /^(?<maj>\d+)\.(?<_>\d+)\.(?<_>\d+)$/ =~ version or
      raise "can't parse version: #{version}"
    "#{maj.to_i + 1}.0.0"
  end

  desc "regenerate metadata.json and .fixtures.yml with updated modules"
  task :update do |t|
    meta = YAML.load_file(metadata_src_file)
    deps = meta["dependencies"]
    meta["dependencies"] = []

    # validate
    module_names = deps.map { |x| x["name"].split("/")[-1] }
    module_names.length == module_names.uniq.length or
      raise "#{metadata_src_file} contains duplicate dependency"

    fixtures = {}

    deps.each do |mod|
      full_name = mod["name"]
      /^(?<_>(?<org_name>\w+)\/)?(?<mod_name>\w+)$/ =~ full_name or
        raise "#{full_name} is not a valid module name"

      mod["info"] and
        puts "INFO: #{mod["info"]}"

      if org_name
        # module from forge
        mod["repo"] and
          raise "field 'repo' makes no sense for modules installed from forge"

        current_version = forge_meta(full_name)["current_release"]["version"]
        version = mod["ref"] || current_version
        version_requirement = ">= #{version} < #{next_maj(version)}"

        if mod["ref"]
          mod["info"] or
            raise "#{full_name} has version pinned with 'ref', but no 'info'. Add a comment in 'info' explaining why a pinned version is needed."

          puts
          puts "WARNING: Using fixed version for module '#{full_name}'. If you need a more specific"
          puts "         version_requirement set than is listed below, you MUST manually edit"
          puts "         metadata.json before committing. Additionally, please be certain that"
          puts "         this pinned version is still actually required, and consider removing"
          puts "         the 'ref' field for #{full_name} from '#{metadata_src_file}'."
          puts
          puts "                                       module: #{full_name}"
          puts "                              current version: #{current_version}"
          puts "                                fixed version: #{version}"
          puts "           generated version_requirement spec: '#{version_requirement}'"
          puts
        end

        meta["dependencies"].push({"name" => full_name, "version_requirement" => version_requirement})
        fixtures["forge_modules"] ||= {}
        fixtures["forge_modules"][mod_name] = {"repo" => full_name, "ref" => version}
        puts "#{full_name} #{version}"
      else
        # module from git
        mod["repo"] or
          raise "field 'repo' required for modules installed from git"

        fixtures["repositories"] ||= []
        fixtures["repositories"][full_name] = {"repo" => mod["repo"]}
        mod["ref"] and
          fixtures["repositories"][full_name]["ref"] = mod["ref"]
      end
    end

    File.write(fixtures_file, {"fixtures" => fixtures}.to_yaml)
    File.write(metadata_file, JSON.pretty_generate(meta) + "\n")
  end
end
