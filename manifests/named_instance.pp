# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# The deployment configuration for a named instance
#
# A named instance is a specific deployment of a project or application.
# For example, fulcrum-testing is its own named instance, distinct from
# fulcrum-production. Named instances tend to be deployed to different
# environments with different configurations. They are distinct entities,
# and tend to have completely separate data and databases.
#
# This resource exports the resources that handle the web, app, database,
# and any other needs required by the named instance.
#
# This type also exports a number of json lines that are used to construct
# an initial configuration for the named instance in moku. That information
# is used by the deploy_host role.
#
# @param init_directory Common. Location to store json files to be used by
#   moku init.
# @param proxy The parameters required by named_instance::proxy
# @param app The parameters required by named_instance::app
# @param path The path where the application will be deployed. By convention, this
#   does not differ from one host to another.
# @param port The application server's bind port
# @param source_url Url to the application's source code, as git-over-ssh.
#   E.g. git@github.com:mlibrary/nebula.git
# @param bind_address Application server's bind address
# @param mysql_host The mysql host
# @param mysql_user The mysql user the instance uses to connect to the database
# @param mysql_password The password for the mysql user
# @param url_root The relative url to this application in its domain
# @param solr_cores A hash of core_title:hash, where the hash is the parameters
#   required by named_instance::solr_params
# @param users A list of users that should be added to the application's group
# @param subservices A list of systemd services that should be restarted with this
#   instance. This list should only include the top level of the service tree; i.e.,
#   given a service my_app_x that depends on my_app_y, you should only include my_app_y.
define nebula::named_instance(
  String        $init_directory,
  Hash          $proxy,
  Hash          $app,
  String        $path,
  Integer       $port,                      # app port
  String        $source_url,
  String        $bind_address = 'localhost',
  String        $mysql_host = 'localhost',
  Optional[String] $mysql_user = undef,
  Optional[String] $mysql_password = undef,
  String        $url_root = '/',
  Hash          $solr_cores = {},
  Array[String] $users = [],
  Array[String] $subservices = [],
) {

  $defaults =   { target  => "${title} deploy init" }

  $bind = "tcp://${bind_address}:${port}";

  # some are only relevant to apache config -- extract

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

  $solr_cores.each |$core_title, $solr_params| {
    nebula::named_instance::solr_params { $core_title:
      solr_params => $solr_params,
      instance    => $title,
      path        => $path,
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

    "${title} deploy init infrastructure.bind":
      content => {infrastructure => {bind => $bind}}.to_json;

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

  Concat_fragment <<| target == "${title} deploy init" |>>

}
