# nebula::profile::interactive
#
# Install packages that are useful for interactive sessions but
# generally not needed on servers where humans rarely log in.
#
# @example
#   include nebula::profile::interactive
class nebula::profile::interactive {
  stdlib::ensure_packages([
    'neovim',
    'tmux',
    'zsh',
    'git',
  ])
}
