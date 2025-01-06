# nebula::profile::root
#
# configure root's home directory
#
# @example
#   include nebula::profile::root
class nebula::profile::root (
  Boolean $manage = true,
) {
  if ($manage) {
    file { '/root/':
      ensure             => directory,
      mode               => '0700',
      source             => 'puppet:///modules/nebula/root/',
      source_permissions => use,
      recurse            => remote,
      purge              => false,
    }

    file { '/root/.bash_profile':
      ensure => absent
    }
  }
}
