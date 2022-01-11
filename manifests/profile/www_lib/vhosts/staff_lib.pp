# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::www_lib::vhosts::staff_lib
#
# staff.lib.umich.edu virtual host
#
# @example
#   include nebula::profile::www_lib::vhosts::staff_lib
#
class nebula::profile::www_lib::vhosts::staff_lib (
  String $prefix,
  String $domain,
  String $ssl_cn = 'apps.staff.lib.umich.edu',
  String $vhost_root = '/www/staff.lib',
  String $docroot = "${vhost_root}/web"
) {

  nebula::apache::www_lib_vhost { 'apps.staff.lib http redirect':
    servername      => "${prefix}apps.staff.${domain}",
    ssl             => false,
    docroot         => $docroot,
    redirect_status => 'permanent',
    redirect_source => '/',
    redirect_dest   => 'https://apps.staff.lib.umich.edu/'
  }

  nebula::apache::www_lib_vhost { 'apps.staff.lib ssl':
    servername                         => "${prefix}apps.staff.${domain}",
    ssl_cn                             => 'apps.staff.lib.umich.edu',
    ssl                                => true,
    usertrack                          => true,
    cosign                             => true,
    cosign_service                     => 'apps.staff.lib.umich.edu',
    docroot                            => $docroot,
    setenvifnocase                     => ['^Authorization$ "(.+)" HTTP_AUTHORIZATION=$1'],
    default_allow_override             => ['AuthConfig','FileInfo','Limit','Options'],

    aliases                            => [
      { scriptalias => '/cgi', path => "${vhost_root}/cgi" }
    ],

    directories                        => [
      {
        provider       => 'directory',
        path           => $docroot,
        options        => ['IncludesNOEXEC','Indexes','FollowSymLinks','MultiViews'],
        allow_override => ['AuthConfig','FileInfo','Limit','Options'],
        require        => $nebula::profile::www_lib::apache::default_access,
        addhandlers    => [{
          extensions => ['.php'],
          # TODO: Extract version or socket path to params/hiera
          handler    => 'proxy:unix:/run/php/php7.3-fpm.sock|fcgi://localhost'
        }],
      },
      {
        provider       => 'directory',
        path           => "${vhost_root}/cgi",
        allow_override => ['None'],
        options        => ['None'],
        require        => $nebula::profile::www_lib::apache::default_access,
      },
      {
        # Deny access to raw php sources by default
        # To re-enable it's recommended to enable access to the files
        # only in specific virtual host or directory
        provider => 'filesmatch',
        path     => '.+\.phps$',
        require  => 'all denied'
      },
      {
        # Deny access to files without filename (e.g. '.php')
        provider => 'filesmatch',
        path     => '^\.ph(ar|p|ps|tml)$',
        require  => 'all denied'
      },
    ],

    # Don't allow passive auth for directories still protected by auth system
    cosign_public_access_off_dirs      => [
      # results in odd looping behavior
      # {
      #   provider => 'location',
      #   path     => '/user/login'
      # },
      {
        provider => 'directory',
        path     => "${docroot}/funds_transfer",
      },
      {
        provider => 'directory',
        path     => "${docroot}/sites/staff.lib.umich.edu.funds_transfer",
      },
      {
        provider => 'directory',
        path     => "${docroot}/linkscan",
      },
      {
        provider => 'directory',
        path     => "${docroot}/linkscan117",
      },
      {
        provider => 'directory',
        path     => "${docroot}/pagerate",
      },
      {
        provider => 'directory',
        path     => "${docroot}/ts",
      },
    ],

    cosign_public_access_off_php5_dirs => [
      {
        provider => 'directory',
        path     => "${docroot}/coral",
      },
      {
        provider => 'directory',
        path     => "${docroot}/ptf",
      },
      {
        provider => 'directory',
        path     => "${docroot}/sites/staff.lib.umich.edu/local",
      },
    ],

    request_headers                    => [
      # Setting remote user for 2.4
      'set X-Remote-User "expr=%{REMOTE_USER}"',
      # Fix redirects being sent to non ssl url (https -> http)
      'set X-Forwarded-Proto "https"',
      # Remove existing X-Forwarded-For headers; mod_proxy will automatically add the correct one.
      'unset X-Forwarded-For',
    ]
  }
}

