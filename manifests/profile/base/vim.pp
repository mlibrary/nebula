# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::base::vim
#
# Configure vim
#
# @example
#   include nebula::profile::base::vim
class nebula::profile::base::vim {
  package { 'vim': }

  package { 'nano':
    ensure  => 'purged',
    require => Package['vim'],
  }

  file { '/etc/vim/vimrc':
    content => template('nebula/profile/base/vimrc.vim.erb'),
    require => Package['vim'],
  }
}
