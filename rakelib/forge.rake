desc "list outdated modules in .fixtures.yml"
task :outdated do |t|
  require "yaml"
  require "net/http"
  require "uri"
  require "json"

  fixtures = YAML.load_file(".fixtures.yml")
  fixtures["fixtures"]["forge_modules"].values.each do |mod|
    repo = mod["repo"]
    slug = repo.tr("/", "-")
    vers = mod["ref"]
    uri = URI.parse "https://forgeapi.puppet.com/v3/modules/#{slug}"

    response = Net::HTTP.get_response(uri)
    raise "failed to fetch #{mod["repo"]}" unless response.code == "200"

    releases = JSON.parse(response.body)["releases"].map { |x| x["version"] }
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
