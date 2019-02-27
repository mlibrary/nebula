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
  package { ['vim', 'vim-gtk', 'vim-nox': }

  file { '/etc/vim/vimrc':
    content => template('nebula/profile/vim/vimrc.vim.erb'),
    require => Package['vim'],
  }
}
