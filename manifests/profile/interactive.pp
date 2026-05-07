# nebula::profile::interactive
#
# Install packages that are useful for interactive sessions but
# generally not needed on servers where humans rarely log in.
#
# @example
#   include nebula::profile::interactive
class nebula::profile::interactive {
  ensure_packages([
    'fd-find',
    'neovim',
    'ripgrep',
    'tmux',
    'zsh',
    'git',
  ])
  file { '/usr/local/bin/fd':
    ensure  => link,
    target  => '/usr/bin/fdfind',
    require => Package['fd-find'],
  }
}
