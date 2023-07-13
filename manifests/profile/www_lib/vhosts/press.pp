# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::www_lib::vhosts::press
#
# press virtual host
#
# @example
#   include nebula::profile::www_lib::vhosts::press
class nebula::profile::www_lib::vhosts::press (
  String $prefix,
  String $domain,
  String $ssl_cn = 'www.press.umich.edu',
  String $docroot = '/www/www.press/public',
  String $bind = '127.0.0.1:31028',
  Integer $num_proc = 10,
  String $script = '/www/www.press/script/puppet-press',
  String $logging_prefix = 'press'
) {
  $servername = "${prefix}www.press.umich.edu"

  file { "${apache::params::logroot}/${logging_prefix}":
    ensure => 'directory',
  }

  $mojo_log_path = "${apache::params::logroot}/${logging_prefix}/mojo"
  file { $mojo_log_path:
    ensure => 'directory',
    owner  => 'nobody',
    group  => 'nogroup',
  }

  logrotate::rule { 'press':
    path          => [ "${mojo_log_path}/press.out", "${mojo_log_path}/press.err" ],
    rotate        => 7,
    rotate_every  => 'day',
    missingok     => true,
    ifempty       => false,
    delaycompress => true,
    compress      => true,
  }


  file { '/usr/local/bin/startup_press':
    ensure  => 'present',
    content => template('nebula/profile/www_lib/vhosts/press/startup_press.erb'),
    notify  => Service['press'],
    mode    => '0755',
  }

  file { '/etc/systemd/system/press.service':
    ensure  => 'present',
    content => template('nebula/profile/www_lib/vhosts/press/press.service.erb'),
    notify  => Service['press'],
  }

  service { 'press':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
  }

  nebula::apache::www_lib_vhost { 'press-http':
    servername     => $servername,
    docroot        => $docroot,
    logging_prefix => "${logging_prefix}/",

    rewrites       => [
      {
        rewrite_rule => '^(.*)$ https://%{HTTP_HOST}$1 [L,R]'
      },
    ],

    directories    => [
      {
        provider      => 'directory',
        path          => $docroot,
        options       => 'FollowSymLinks',
        allowoverride => 'None',
        require       => $nebula::profile::www_lib::apache::default_access,
      },
    ],
  }

  nebula::apache::www_lib_vhost { 'press-https':
    servername      => $servername,
    docroot         => $docroot,
    logging_prefix  => "${logging_prefix}/",
    ssl             => true,
    ssl_cn          => $ssl_cn,
    setenv          => ['HTTPS on'],

    rewrites        => [
      {
        rewrite_cond => [
          '%{DOCUMENT_ROOT}/%{REQUEST_URI} !-f',
        ],
        rewrite_rule => "^(.*) http://${bind}\$1 [P]"
      }
    ],

    directories     => [
      {
        provider      => 'directory',
        path          => $docroot,
        options       => 'FollowSymLinks',
        allowoverride => 'None',
        require       => $nebula::profile::www_lib::apache::default_access,
      },
    ],

    custom_fragment => @("EOT")
      ProxyPassReverse / http://${bind}
      ProxyPassReverse / https://${bind}
    | EOT
  }

  cron { 'check press fcgi':
    user    => 'root',
    command => '/usr/local/bin/check_press &> /dev/null',
    hour    => '*',
    minute  => '*',
  }

  file { '/usr/local/bin/check_press':
    mode    => '0755',
    content => template('nebula/profile/www_lib/check_press.sh.erb'),
  }
}
