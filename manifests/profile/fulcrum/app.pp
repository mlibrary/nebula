# Copyright (c) 2021-2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::fulcrum::app

class nebula::profile::fulcrum::app (
  Array $authorized_keys = [],
  String $private_address_template = '192.168.0.%s',
  String $image_magick_secret = 'secret',
) {
  $jdk_version = lookup('nebula::jdk_version')

  class { 'nebula::profile::networking::private':
    address_template => $private_address_template
  }

  ensure_packages([
    'clamav',
    'clamav-daemon',
    'clamav-freshclam',
    'libclamav-dev',
    'imagemagick',
    'ffmpeg',
    'ghostscript',
    'libreoffice',
    'libjemalloc2',
    'netpbm-sf',
    "openjdk-${jdk_version}-jre-headless",
    'pdftk',
    'qpdf',
    'shared-mime-info',
    'unzip',
    'zip',
    'screen',
    'poppler-utils',
  ])

  include nebula::profile::nodejs

  exec { 'npm install -g yarn':
    path    => '/bin:/usr/bin',
    creates => '/usr/bin/yarn',
    require => Package['nodejs'],
  }

  nebula::file::ssh_keys { '/fulcrum/.ssh/authorized_keys':
    keys   => $authorized_keys,
    secret => true,
    owner  => 'fulcrum',
    group  => 'fulcrum',
  }

  file { '/etc/sudoers.d/fulcrum':
    content => template('nebula/profile/fulcrum/sudoers.erb'),
    require => Package['sudo'],
  }

  file { '/fulcrum/data':
    ensure  => directory,
    owner   => 'fulcrum',
    group   => 'fulcrum',
    require => User['fulcrum'],
  }

  # "Long term temp", for bootsnap, etc.; never networked
  file { '/fulcrum/tmp':
    ensure  => directory,
    owner   => 'fulcrum',
    group   => 'fulcrum',
    require => User['fulcrum'],
  }

  file { '/fulcrum/app':
    ensure  => directory,
    owner   => 'fulcrum',
    group   => 'fulcrum',
    require => User['fulcrum'],
  }

  file { '/fulcrum/app/releases':
    ensure  => directory,
    owner   => 'fulcrum',
    group   => 'fulcrum',
    require => File['/fulcrum/app'],
  }

  file { '/fulcrum/app/shared':
    ensure  => directory,
    owner   => 'fulcrum',
    group   => 'fulcrum',
    require => File['/fulcrum/app'],
  }

  file { '/fulcrum/app/shared/tmp':
    ensure  => directory,
    owner   => 'fulcrum',
    group   => 'fulcrum',
    require => File['/fulcrum/app/shared'],
  }

  file { '/fulcrum/app/shared/public':
    ensure  => directory,
    owner   => 'fulcrum',
    group   => 'fulcrum',
    require => File['/fulcrum/app/shared'],
  }

  archive { '/tmp/fits.zip':
    ensure        => present,
    extract       => true,
    creates       => '/usr/local/fits/fits.sh',
    extract_path  => '/usr/local/fits',
    source        => 'https://projects.iq.harvard.edu/files/fits/files/fits-1.3.0.zip',
    checksum      => '9c1b020afdd2e9a65a62128fa5ec6a6f86f77de9',
    checksum_type => 'sha1',
    cleanup       => true,
    require       => [
      File['/usr/local/fits'],
      Package['unzip'],
    ],
  }

  file { '/usr/local/fits':
    ensure => directory,
  }

  file { '/usr/local/bin/fits.sh':
    ensure => 'symlink',
    target => '/usr/local/fits/fits.sh',
  }

  file { '/etc/ImageMagick-6/policy.xml':
    content => template('nebula/profile/fulcrum/imagemagick-policy.xml.erb'),
    require => Package['imagemagick'],
  }

  file { '/usr/local/fits/xml/fits.xml':
    content => template('nebula/profile/fulcrum/fits.xml.erb'),
    require => Archive['/tmp/fits.zip'],
  }

  file { '/etc/systemd/system/fulcrum.target':
    content => template('nebula/profile/fulcrum/fulcrum.target.erb'),
    notify  => Service['fulcrum'],
    require => [
      File['/etc/systemd/system/fulcrum-rails.service'],
      File['/etc/systemd/system/fulcrum-resque.service'],
    ]
  }

  file { '/etc/systemd/system/fulcrum-rails.service':
    content => template('nebula/profile/fulcrum/fulcrum-rails.service.erb'),
    notify  => Service['fulcrum'],
  }

  file { '/etc/systemd/system/fulcrum-resque.service':
    content => template('nebula/profile/fulcrum/fulcrum-resque.service.erb'),
    notify  => Service['fulcrum'],
  }

  file { '/etc/default/fulcrum':
    content => template('nebula/profile/fulcrum/fulcrum.env.erb'),
    notify  => Service['fulcrum'],
  }

  file_line { 'fulcrum-profile-rails-env':
    ensure => present,
    path   => '/fulcrum/.profile',
    line   => 'export RAILS_ENV=production',
    match  => '^export RAILS_ENV=',
    require => User['fulcrum'],
  }

  file_line { 'fulcrum-profile-bootsnap-cache':
    ensure  => present,
    path    => '/fulcrum/.profile',
    line    => 'export BOOTSNAP_CACHE_DIR=/fulcrum/tmp',
    match   => '^export BOOTNSAP_CACHE_DIR=',
    require => User['fulcrum'],
  }

  service { 'fulcrum':
    name    => 'fulcrum.target',
    ensure  => 'running',
    enable  => true,
    require => [
      File['/etc/systemd/system/fulcrum.target'],
    ],
  }
}
