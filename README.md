# Puppet Nebula

## Development

### with locally installed ruby

```sh
# ensure you're using the correct ruby (higher versions will _probably_ work)
% cat .ruby-version
3.2
% ruby -v
ruby 3.2.11

# bundle
bundle

# list all rake tasks
bundle exec rake -T

# run all tests
bundle exec rake parallel_spec

# run any single test
bundle exec rake fixtures:prep
bundle exec rspec specs/path/to/a_spec.rb

# lint .rb files
gem install standard
standardrb
standardrb --fix

# lint .pp files
bundle exec rake syntax
bundle exec rake lint
bundle exec rake lint_fix

# check puppet module dependencies for available updates
bundle exec rake forge:outdated
# update dependencies
vi rakelib/metadata.yaml
bundle exec rake forge:update
# test for dependency conflicts
bundle exec rake librarian
```

### with `docker compose`
(or `podman compose`)

```sh
docker compose build
docker compose run spec_prep
docker compose run specs
docker compose run lint
docker compose run lint_fix
# or…
docker compose run specs bundle exec rspec specs/path/to/a_spec.rb
docker compose run specs bundle exec rake spec_standalone
```

## Repo maintenance
* `Gemfile` is copied from voxpupuli defaults, with some local additions. See one of their module repos for a template.
* `/spec/spec_helper.rb` is from the PDK, which we used to use. TODO: use voxpupuli template here as well.
