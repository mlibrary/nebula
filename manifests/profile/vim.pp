# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::vim
#
# Configure vim
#
# @example
#   include nebula::profile::vim
class nebula::profile::vim {
  package { 'vim': }

  # Replace default vimrc
  # This is only here to eliminate our previous customizations
  # Remove after December 2024
  file { '/etc/vim/vimrc':
    source  => "puppet:///modules/nebula/default/${facts['os']['distro']['codename']}${title}",
    require => Package['vim'],
  }

  file { '/etc/vim/vimrc.local':
    content => template('nebula/profile/vim/vimrc.local.erb'),
    require => Package['vim'],
  }

  # Write an empty /root/.vimrc to prevent vim from automatically
  # loading /usr/share/vim/vim*/defaults.vim
  file { '/root/.vimrc':
    ensure => 'file',
    mode   => '0644',
  }
}
