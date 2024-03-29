# Copyright (c) 2018, 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::ruby
#
# Install rbenv and all supported versions of ruby.
#
# @param global_version The system default ruby version
# @param supported_versions All ruby versions to install
# @param install_dir Install directory
# @param plugins rbenv::plugins to use
#
# @example
#   include nebula::profile::ruby
class nebula::profile::ruby (
  String $global_version,
  String $bundler_version,
  Array  $supported_versions,
  String $install_dir,
  Array  $plugins,
  Array  $gems,
  # AEIM-2776 - We have a temporary blacklist on specific versions that are
  # installed in some places, but should not be managed at all. If an installed
  # version matches this regex, it will not appear in the catalogue at all.
  # These should be removed as soon as practical in coordination with devs.
  String $manage_blacklist = '^jruby-(1\.7|9\.0)\.',
) {

  ensure_packages([
    'autoconf',
    'build-essential',
    'bison',
    'libssl-dev',
    'libyaml-dev',
    'libreadline-dev',
    'zlib1g-dev',
    'libsqlite3-dev',
    'libncurses5-dev',
    'libffi-dev',
    'libgdbm-dev'
  ])

  case $::os['release']['major'] {
    '8':     { package { 'libmysqlclient-dev': } }
    '9':     { package { 'default-libmysqlclient-dev': } }
    default: { package { 'libmariadb-dev': } }
  }

  class { 'rbenv':
    install_dir => $install_dir,
  }

  $plugins.each |$plugin| {
    rbenv::plugin { $plugin: }
  }

  rbenv::build { $global_version:
    bundler_version => $bundler_version,
    global          => true,
  }

  $gems.each |$gem| {
    rbenv::gem { "${gem[gem]} ${global_version}":
      gem          => $gem['gem'],
      version      => $gem['version'],
      ruby_version => $global_version,
      require      => Rbenv::Build[$global_version],
    }
  }

  $supported_versions.each |$version| {
    # Ruby < 2.4 is incompatible with debian stretch
    unless $::os['release']['major'] == '9' and $version =~ /^2\.3\./ {
      unless $version =~ $manage_blacklist {
        unless $version == $global_version {
          rbenv::build { $version:
            bundler_version => $bundler_version,
          }

          $gems.each |$gem| {
            rbenv::gem { "${gem[gem]} ${version}":
              gem          => $gem['gem'],
              version      => $gem['version'],
              ruby_version => $version,
              require      => Rbenv::Build[$version],
            }
          }
        }
      }
    }
  }

  $::ruby_versions.each |$version| {
    unless $version in $supported_versions {
      unless $version == $global_version {
        exec { "rbenv uninstall ${version}":
          command     => "rbenv uninstall -f ${version}",
          environment => "RBENV_ROOT=${install_dir}",
          path        => "${install_dir}/shims:${install_dir}/bin:/usr/bin:/bin",
        }

        # This uninstall exec requires every rbenv::build. Don't
        # uninstall anything until everything is installed.
        Rbenv::Build <| |> -> Exec <| title == "rbenv uninstall ${version}" |>
      }
    }
  }

  file { '/usr/local/rubytests/':
    ensure  => 'directory',
  }

  file { '/etc/cron.daily/ruby-health-check':
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('nebula/profile/ruby/ruby-health-check.sh.erb'),
  }

  file { '/usr/local/rubytests/testall.sh':
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('nebula/profile/ruby/testall.sh.erb'),
  }

  file { '/usr/local/rubytests/testruby.sh':
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('nebula/profile/ruby/testruby.sh.erb'),
  }
}
