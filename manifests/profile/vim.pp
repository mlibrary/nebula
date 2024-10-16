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

  file { '/etc/vim/vimrc':
    content => template('nebula/profile/vim/vimrc.vim.erb'),
    require => Package['vim'],
  }

  # Write an empty /root/.vimrc to prevent vim from automatically
  # loading /usr/share/vim/vim*/defaults.vim
  file { '/root/.vimrc':
    ensure => 'file',
    mode   => '0644',
  }
}
