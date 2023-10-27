# Copyright (c) 2023 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::authz_test {
  include nebula::profile::logrotate

  include nebula::profile::apache
  include nebula::profile::apache::authz_umichlib

  include apache::mod::alias
  include apache::mod::auth_basic
  include apache::mod::authn_core
  include apache::mod::authn_file
  include apache::mod::authz_user
  include apache::mod::autoindex
  include apache::mod::cgi
  include apache::mod::dir
  include apache::mod::env
  include apache::mod::headers
  include apache::mod::include
  include apache::mod::mime
  include apache::mod::negotiation
  include apache::mod::proxy
  include apache::mod::proxy_http
  include apache::mod::rewrite
  include apache::mod::reqtimeout
  include apache::mod::setenvif
  include apache::mod::ssl

  class { 'nebula::profile::ssl_keypair':
    common_name => 'legacy.lauth.lib.umich.edu',
  }

  ensure_packages([
    'build-essential',
    'libjson-xs-perl',
  ])
  nebula::cpan { ['CGI']: }
  Package <| |> -> Nebula::Cpan <| |>

  file { '/lauth':
    ensure => directory,
    mode => '755',
  }

  file { '/lauth/test-site':
    ensure => directory,
    recurse => true,
    source => 'puppet:///authz-test-site',
    require => File['/lauth'],
  }

  file { '/lauth/test-site/cgi/delegated':
    mode => '0755',
    require => File['/lauth/test-site'],
  }

  file { '/etc/apache2/sites-enabled/test.conf':
    content => '# an allowed file'
  }

  firewall { '200 HTTP(S): public':
    proto  => 'tcp',
    dport  => [80, 443],
    state  => 'NEW',
    action => 'accept',
  }
}
