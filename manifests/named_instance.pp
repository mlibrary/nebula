
# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# The deployment configuration for a named instance
#
# @example
define nebula::named_instance(
  String        $init_directory,
  Hash          $proxy,
  Hash          $app,
  String        $path,
  Integer       $port,                      # app port
  String        $source_url,
  String        $mysql_host = 'localhost',
  Optional[String] $mysql_user = undef,
  Optional[String] $mysql_password = undef,
  String        $url_root = '/',
  Hash          $solr_cores = {},
  Array[String] $users = [],
  Array[String] $subservices = [],
) {

  $defaults =   { target  => "${title} deploy init" }

  @@nebula::named_instance::app { $title:
    *              => $app,
    path           => $path,
    mysql_host     => $mysql_host,
    mysql_user     => $mysql_user,
    mysql_password => $mysql_password,
    users          => $users,
    subservices    => $subservices
  }

  @@nebula::named_instance::proxy { $title:
    *        => $proxy,
    url_root => $url_root,
    port     => $port,
    path     => $path
  }

  $solr_cores.keys.each |$index, $core_title| {
    nebula::named_instance::solr_params { $core_title:
      solr_params => $solr_cores[$core_title],
      instance    => $title,
      path        => $path,
      index       => $index + 1
    }
  }

  concat_file { "${title} deploy init":
    path   => "${init_directory}/${title}.json",
    format => 'json-pretty',
  }

  if( $mysql_user and $mysql_password) {
    concat_fragment {
      default:
        * => $defaults;

      "${title} deploy init infrastructure.db.url":
        content => {infrastructure => {db => {url => "mysql2://${mysql_user}:${mysql_password}@${mysql_host}:3306/${title}?encoding=utf8&pool=5&reconnect=true&timeout=5000"}}}.to_json;

      "${title} deploy init infrastructure.db.adapter":
        content => {infrastructure => {db => {adapter => 'mysql2'}}}.to_json;

      "${title} deploy init infrastructure.db.username":
        content => {infrastructure => {db => {username => $mysql_user}}}.to_json;

      "${title} deploy init infrastructure.db.password":
        content => {infrastructure => {db => {password => $mysql_password}}}.to_json;

      "${title} deploy init infrastructure.db.host":
        content => {infrastructure => {db => {host => $mysql_host}}}.to_json;

      "${title} deploy init infrastructure.db.port":
        content => {infrastructure => {db => {port => 3306}}}.to_json;

      "${title} deploy init infrastructure.db.database":
        content => {infrastructure => {db => {database => $title}}}.to_json;
    }
  }

  concat_fragment {
    default:
      * => $defaults;

    "${title} deploy init instance.source.url":
      content => {instance => {source => {url => $source_url}}}.to_json;

    "${title} deploy init instance.source.commitish":
      content => {instance => {source => {commitish => 'master'}}}.to_json;

    "${title} deploy init instance.deploy.url":
      content => {instance => {deploy => {url => 'git@github.com:mlibrary/moku-deploy'}}}.to_json;

    "${title} deploy init instance.deploy.commitish":
      content => {instance => {deploy => {commitish => $title}}}.to_json;

    "${title} deploy init instance.infrastructure.url":
      content => {instance => {infrastructure => {url => 'git@github.com:mlibrary/moku-infrastructure'}}}.to_json;

    "${title} deploy init instance.infrastructure.commitish":
      content => {instance => {infrastructure => {commitish => $title}}}.to_json;

    "${title} deploy init instance.dev.url":
      content => {instance => {dev => {url => 'git@github.com:mlibrary/moku-dev'}}}.to_json;

    "${title} deploy init instance.dev.commitish":
      content => {instance => {dev => {commitish => $title}}}.to_json;

    "${title} deploy init permissions.deploy":
      content => {permissions => { deploy => $users}}.to_json;

    "${title} deploy init permissions.edit":
      content => {permissions => { edit => $users}}.to_json;

    "${title} deploy init infrastructure.base_dir":
      content => {infrastructure => {base_dir => $path}}.to_json;

    "${title} deploy init infrastructure.relative_url_root":
      content => {infrastructure => {relative_url_root => $url_root}}.to_json;

    "${title} deploy init deploy.deploy_dir":
      content => {deploy => {deploy_dir => $path}}.to_json;

    "${title} deploy init deploy.env":
      content => {'deploy' => {'env' => {'rack_env' => 'production', 'rails_env' => 'production'}}}.to_json;

    "${title} deploy init deploy.systemd_services":
      content => {deploy => {systemd_services => $subservices}}.to_json;

    "${title} deploy init deploy.sites.user":
      content => {deploy => {sites => {user => $title}}}.to_json;
  }

}
