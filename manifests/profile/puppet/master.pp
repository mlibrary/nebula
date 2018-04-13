# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Puppet Master config
#
# @example
#   include nebula::profile::puppet::master
class nebula::profile::puppet::master (
  $fileservers,
  $r10k_source,
) {
  $rbenv = lookup('nebula::profile::ruby::install_dir')

  service { 'puppetserver':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    require    => Exec["${rbenv}/shims/r10k deploy environment production"],
  }

  exec { "${rbenv}/shims/r10k deploy environment production":
    creates => '/etc/puppetlabs/code/environments/production',
    require => File['/etc/puppetlabs/r10k/r10k.yaml'],
    notify  => Exec["${rbenv}/shims/librarian-puppet update"],
  }

  exec { "${rbenv}/shims/librarian-puppet update":
    cwd         => '/etc/puppetlabs/code/environments/production',
    refreshonly => true,
  }

  file { '/etc/puppetlabs/r10k/r10k.yaml':
    content => template('nebula/profile/puppet/master/r10k.yaml.erb'),
  }

  file { '/etc/puppetlabs/r10k':
    ensure  => 'directory',
    require => Package['puppetserver'],
  }

  file { '/etc/puppetlabs/puppet/fileserver.conf':
    content => template('nebula/profile/puppet/master/fileserver.conf.erb'),
    require => Package['puppetserver'],
  }

  $fileservers.each |$name, $path| {
    file { $path:
      ensure  => 'directory',
      source  => "puppet:///${name}",
      recurse => true,
      require => Package['puppetserver'],
    }
  }

  package { 'puppetserver':
    require => Rbenv::Gem['r10k', 'librarian-puppet'],
  }

  include nebula::profile::ruby
  $global_version = lookup('nebula::profile::ruby::global_version')

  ['r10k', 'librarian-puppet'].each |$gem| {
    rbenv::gem { $gem:
      ruby_version => $global_version,
      require      => [
        Class['nebula::profile::ruby'],
        Rbenv::Build[$global_version],
      ],
    }
  }

  tidy { '/opt/puppetlabs/server/data/puppetserver/reports':
    age     => '1w',
    recurse => true,
  }
}
