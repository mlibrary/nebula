# Puppet Nebula

## Development

### with locally installed ruby

```sh
# ensure you're using the correct ruby (higher versions will _probably_ work)
% cat .ruby-version
3.2
% ruby -v
ruby 3.2.10

# bundle
bundle install

# list all rake tasks
bin/rake -T

# run all tests
bin/rake

# run any single test
bin/rake prep
bin/rspec specs/path/to/a_spec.rb

# optionally, remove test fixtures
bin/rake clean

# lint
bin/rake validate # includes syntax task, other misc. checks
bin/rake lint
bin/standardrb # [Standard Ruby](https://github.com/standardrb/standard)

# check puppet module dependencies for available updates
bin/rake forge:outdated
# update dependencies
vi rakelib/metadata.yaml
bin/rake forge:update
# test for dependency conflicts
bin/rake librarian
bin/rake clean
```

### with `docker compose`
```sh
docker compose build
docker compose run spec_prep
docker compose run specs
# or…
docker compose run specs bundle exec rspec specs/path/to/a_spec.rb
docker compose run specs bundle exec rake spec_standalone
```

## Repo maintenance
* `Gemfile` is copied from voxpupuli defaults, with some local additions. See one of their module repos for a template.
* `/spec/spec_helper.rb` is from the PDK, which we used to use. TODO: use voxpupuli template here as well.
