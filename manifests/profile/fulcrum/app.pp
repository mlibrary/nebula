# Copyright (c) 2021-2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::fulcrum::app

class nebula::profile::fulcrum::app (
  Array $authorized_keys = [],
  String $private_address_template = '192.168.0.%s',
  String $image_magick_secret = 'secret',
) {
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
    'netpbm',
    'temurin-11-jre',
    'pdftk',
    'qpdf',
    'shared-mime-info',
    'unzip',
    'zip',
    'screen',
    'mediainfo',
    'libmediainfo-dev',
    'pkg-config',
    'libyaml-perl',
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

  file { '/fulcrum':
    ensure => 'directory',
    owner  => 'fulcrum',
    group  => 'fulcrum',
    mode   => '0755',
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
    source        => 'https://github.com/fitstool/fits/releases/download/1.6.0/fits-1.6.0.zip',
    checksum      => '32e436effe7251c5b067ec3f02321d5baf4944b3f0d1010fb8ec42039d9e3b73',
    checksum_type => 'sha256',
    cleanup       => true,
    require       => [
      File['/usr/local/fits'],
      Package['unzip'],
    ],
  }

  file { '/usr/local/fits':
    ensure => directory,
  }

  file { '/etc/ImageMagick-7/policy.xml':
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
    ensure  => present,
    path    => '/fulcrum/.profile',
    line    => 'export RAILS_ENV=production',
    match   => '^export RAILS_ENV=',
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
    ensure  => 'running',
    name    => 'fulcrum.target',
    enable  => true,
    require => [
      File['/etc/systemd/system/fulcrum.target'],
    ],
  }

  service { 'fulcrum-resque':
    ensure  => 'running',
    name    => 'fulcrum-resque.service',
    enable  => true,
    require => [
      File['/etc/systemd/system/fulcrum-resque.service'],
    ],
  }

  service { 'fulcrum-rails':
    ensure  => 'running',
    name    => 'fulcrum-rails.service',
    enable  => true,
    require => [
      File['/etc/systemd/system/fulcrum-rails.service'],
    ],
  }

  service { 'clamav-freshclam':
    ensure  => 'running',
    require => Package['clamav-freshclam'],
  }
}
