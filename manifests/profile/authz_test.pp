# Copyright (c) 2023 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::authz_test {
  include nebula::profile::logrotate

  include nebula::profile::apache
  include nebula::profile::apache::authz_umichlib

  include apache::mod::auth_basic
  include apache::mod::authn_core
  include apache::mod::authn_file
  include apache::mod::authz_user
  include apache::mod::cgi
  include apache::mod::env
  include apache::mod::headers
  include apache::mod::include
  include apache::mod::setenvif

  ensure_packages([
    'build-essential',
    'libjson-xs-perl',
  ])
  nebula::cpan { ['CGI']: }
  Package <| |> -> Nebula::Cpan <| |>

}
