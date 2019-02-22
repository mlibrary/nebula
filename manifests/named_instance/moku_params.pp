# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::moku
#
# @example
#   include nebula::profile::moku
define nebula::named_instance::moku_params  (
  String $instance,
  Array[String] $users,
  Array[String] $subservices,
  String $source_url,
  Optional[String] $mysql_user,
  Optional[String] $mysql_password,
  Optional[String] $mysql_host,
  String $path,
  String $url_root,
  String $hostname,
  String $datacenter,
) {

  concat_fragment { "${title} deploy init deploy.sites.nodes.${hostname}":
    target  => "${title} deploy init",
    content => "{\"deploy\": {\"sites\": {\"nodes\": {\"${hostname}\": \"${datacenter}\"}}}}",
  }

  $defaults =   { target  => "${instance} deploy init" }


  $init_directory = Class['Nebula::Profile::Moku']['init_directory']

  ensure_resource('concat_file',"${instance} deploy init",
  {
    path   => "${init_directory}/${instance}.json",
    format => 'json-pretty',
    })

    if( $mysql_user and $mysql_password) {
      ensure_resources('concat_fragment',
      {
        "${instance} deploy init infrastructure.db.url"             => {
          content => "{\"infrastructure\": {\"db\": {\"url\": \"mysql2://${mysql_user}:${mysql_password}@${mysql_host}:3306/${instance}?encoding=utf8&pool=5&reconnect=true&timeout=5000\"}}}",
        },

        "${instance} deploy init infrastructure.db.adapter"         => {
          content => "{\"infrastructure\": {\"db\": {\"adapter\": \"mysql2\"}}}",
        },

        "${instance} deploy init infrastructure.db.username"        => {
          content => "{\"infrastructure\": {\"db\": {\"username\": \"${mysql_user}\"}}}",
        },

        "${instance} deploy init infrastructure.db.password"        => {
          content => "{\"infrastructure\": {\"db\": {\"password\": \"${mysql_password}\"}}}",
        },

        "${instance} deploy init infrastructure.db.host"            => {
          content => "{\"infrastructure\": {\"db\": {\"host\": \"${mysql_host}\"}}}",
        },

        "${instance} deploy init infrastructure.db.port"            => {
          content => "{\"infrastructure\": {\"db\": {\"port\": \"3306\"}}}",
        },

        "${instance} deploy init infrastructure.db.database"        => {
          content => "{\"infrastructure\": {\"db\": {\"database\": \"${instance}\"}}}",
        },
        }, $defaults)
    }

    ensure_resources('concat_fragment',
    {
      "${instance} deploy init instance.source.url"               => {
        content => "{\"instance\": {\"source\": {\"url\": \"${source_url}\"}}}",
      },

      "${instance} deploy init instance.source.commitish"         => {
        content => '{"instance": {"source": {"commitish": "master"}}}',
      },

      "${instance} deploy init instance.deploy.url"               => {
        content => '{"instance": {"deploy": {"url": "git@github.com:mlibrary/moku-deploy"}}}',
      },

      "${instance} deploy init instance.deploy.commitish"         => {
        content => "{\"instance\": {\"deploy\": {\"commitish\": \"${instance}\"}}}",
      },

      "${instance} deploy init instance.infrastructure.url"       => {
        content => '{"instance": {"infrastructure": {"url": "git@github.com:mlibrary/moku-infrastructure"}}}',
      },

      "${instance} deploy init instance.infrastructure.commitish" => {
        content => "{\"instance\": {\"infrastructure\": {\"commitish\": \"${instance}\"}}}",
      },

      "${instance} deploy init instance.dev.url"                  => {
        content => '{"instance": {"dev": {"url": "git@github.com:mlibrary/moku-dev"}}}',
      },

      "${instance} deploy init instance.dev.commitish"            => {
        content => "{\"instance\": {\"dev\": {\"commitish\": \"${instance}\"}}}",
      },

      "${instance} deploy init permissions.deploy"                => {
        content => {permissions => { deploy => $users}}.to_json,
      },

      "${instance} deploy init permissions.edit"                  => {
        content => {permissions => { edit => $users}}.to_json,
      },

      "${instance} deploy init infrastructure.base_dir"           => {
        content => "{\"infrastructure\": {\"base_dir\": \"${path}\"}}",
      },

      "${instance} deploy init infrastructure.relative_url_root"  => {
        content => "{\"infrastructure\": {\"relative_url_root\": \"${url_root}\"}}",
      },

      "${instance} deploy init deploy.deploy_dir"                 => {
        content => "{\"deploy\": {\"deploy_dir\": \"${path}\"}}",
      },

      "${instance} deploy init deploy.env"                        => {
        content => '{"deploy": {"env": {"rack_env": "production", "rails_env": "production"}}}',
      },

      "${instance} deploy init deploy.systemd_services"           => {
        content => {deploy => {systemd_services => $subservices}}.to_json(),
      },

      "${instance} deploy init deploy.sites.user"                 =>  {
        content => "{\"deploy\": {\"sites\": {\"user\": \"${instance}\"}}}",
      },
      }, $defaults)

}
