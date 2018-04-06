# Copyright (c) 2018 The Regents of the University of Michigan.
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
  Array  $supported_versions,
  String $install_dir,
  Array  $plugins,
) {
  class { 'rbenv':
    install_dir => $install_dir,
  }

  $plugins.each |$plugin| {
    rbenv::plugin { $plugin: }
  }

  rbenv::build { $global_version:
    bundler_version => '~>1.14',
    global          => true,
  }

  rbenv::gem { "puma-${global_version}":
    gem => 'puma',
    ruby_version => $global_version,
    require => [
      Rbenv::Build[$global_version]
    ]
  }

  $supported_versions.each |$version| {
    # Ruby < 2.4 is incompatible with debian stretch
    unless $::os['release']['major'] == '9' and $version =~ /^2\.3\./ {
      unless $version == $global_version {
        rbenv::build { $version:
          bundler_version => '~>1.14',
        }
        rbenv::gem { "puma-${version}":
          gem => 'puma',
          ruby_version => $version,
          require => [
            Rbenv::Build[$version],
          ],
        }
      }
    }
  }
}
