Puppet Nebula
=============

# Development

1. git clone
2. `docker-compose build`
3. `docker-compose run spec_prep`
4. `docker-compose run specs`

or:

```bash
docker-compose run specs bundle exec rspec specs/path/to/a_spec.rb
docker-compose run specs bundle exec rake spec_standalone
```
