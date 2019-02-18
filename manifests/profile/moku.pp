# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::moku
#
# @example
#   include nebula::profile::moku
class nebula::profile::moku (
  String $init_directory = '/etc/moku/init',
) {
  lookup('nebula::named_instances').each |$name, $instance| {
    $url = $instance['url']
    $path = $instance['path']

    if has_key($instance, 'users') {
      $users = to_json($instance['users'])
    } else {
      $users = '[]'
    }

    if has_key($instance, 'subservices') {
      $subservices = to_json($instance['subservices'])
    } else {
      $subservices = '[]'
    }

    concat_file { "${name} deploy init":
      path   => "${init_directory}/${name}.json",
      format => 'json-pretty',
    }

    Concat_fragment <<| target == "${name} deploy init" |>>

    concat_fragment {
      default:
        target  => "${name} deploy init",
        ;

      "${name} deploy init instance.source.url":
        content => "{\"instance\": {\"source\": {\"url\": \"${url}\"}}}",
        ;

      "${name} deploy init instance.source.commitish":
        content => '{"instance": {"source": {"commitish": "master"}}}',
        ;

      "${name} deploy init instance.deploy.url":
        content => '{"instance": {"deploy": {"url": "git@github.com:mlibrary/moku-deploy"}}}',
        ;

      "${name} deploy init instance.deploy.commitish":
        content => "{\"instance\": {\"deploy\": {\"commitish\": \"${name}\"}}}",
        ;

      "${name} deploy init instance.infrastructure.url":
        content => '{"instance": {"infrastructure": {"url": "git@github.com:mlibrary/moku-infrastructure"}}}',
        ;

      "${name} deploy init instance.infrastructure.commitish":
        content => "{\"instance\": {\"infrastructure\": {\"commitish\": \"${name}\"}}}",
        ;

      "${name} deploy init instance.dev.url":
        content => '{"instance": {"dev": {"url": "git@github.com:mlibrary/moku-dev"}}}',
        ;

      "${name} deploy init instance.dev.commitish":
        content => "{\"instance\": {\"dev\": {\"commitish\": \"${name}\"}}}",
        ;

      "${name} deploy init permissions.deploy":
        content => "{\"permissions\": {\"deploy\": ${users}}}",
        ;

      "${name} deploy init permissions.edit":
        content => "{\"permissions\": {\"edit\": ${users}}}",
        ;

      "${name} deploy init infrastructure.db.url":
        content => "{\"infrastructure\": {\"db\": {\"url\": \"TODO\"}}}",
        ;

      "${name} deploy init infrastructure.db.adapter":
        content => "{\"infrastructure\": {\"db\": {\"adapter\": \"TODO\"}}}",
        ;

      "${name} deploy init infrastructure.db.username":
        content => "{\"infrastructure\": {\"db\": {\"username\": \"TODO\"}}}",
        ;

      "${name} deploy init infrastructure.db.password":
        content => "{\"infrastructure\": {\"db\": {\"password\": \"TODO\"}}}",
        ;

      "${name} deploy init infrastructure.db.host":
        content => "{\"infrastructure\": {\"db\": {\"host\": \"TODO\"}}}",
        ;

      "${name} deploy init infrastructure.db.port":
        content => "{\"infrastructure\": {\"db\": {\"port\": \"TODO\"}}}",
        ;

      "${name} deploy init infrastructure.db.database":
        content => "{\"infrastructure\": {\"db\": {\"database\": \"TODO\"}}}",
        ;

      "${name} deploy init infrastructure.base_dir":
        content => "{\"infrastructure\": {\"base_dir\": \"TODO\"}}",
        ;

      "${name} deploy init infrastructure.bind":
        content => "{\"infrastructure\": {\"bind\": \"TODO\"}}",
        ;

      "${name} deploy init infrastructure.relative_url_root":
        content => "{\"infrastructure\": {\"relative_url_root\": \"TODO\"}}",
        ;

      "${name} deploy init infrastructure.redis.1":
        content => "{\"infrastructure\": {\"redis\": {\"1\": \"TODO\"}}}",
        ;

      "${name} deploy init infrastructure.solr.1":
        content => "{\"infrastructure\": {\"solr\": {\"1\": \"TODO\"}}}",
        ;

      "${name} deploy init deploy.deploy_dir":
        content => "{\"deploy\": {\"deploy_dir\": \"${path}\"}}",
        ;

      "${name} deploy init deploy.env.rack_env":
        content => '{"deploy": {"env": {"rack_env": "production"}}}',
        ;

      "${name} deploy init deploy.systemd_services":
        content => "{\"deploy\": {\"systemd_services\": ${subservices}}}",
        ;

      "${name} deploy init deploy.sites.user":
        content => "{\"deploy\": {\"sites\": {\"user\": \"${name}\"}}}",
        ;
    }
  }
}
