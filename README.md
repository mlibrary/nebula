# Puppet Nebula

## Development

### with locally installed ruby

```sh
# ensure you're using the correct ruby (higher versions will _probably_ work)
% cat .ruby-version
3.2
% ruby -v
ruby 3.2.6

# bundle
bundle

# run all tests
bundle exec rake parallel_spec

# run any single test
bundle exec rake fixtures:prep
bundle exec rspec specs/path/to/a_spec.rb

# lint
bundle exec standardrb # lint .rb files
bundle exec rake lint # lint .pp files

# puppet module dependencies
bundle exec rake outdated
bundle exec rake librarian
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
