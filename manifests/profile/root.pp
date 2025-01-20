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
    file {
      default:
        ensure => file,
        mode   => '0644',
      ;
      '/root/.bashrc': source => 'puppet:///modules/nebula/root/.bashrc';
      '/root/.profile': source => 'puppet:///modules/nebula/root/.profile';
      '/root/.bash_profile': ensure => absent;
    }
  }
}
