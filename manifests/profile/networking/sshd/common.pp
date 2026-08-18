# nebula::profile::networking::sshd::common
#
# Install openssh-server, enable ssh service
#
# @example
#   include nebula::profile::networking::sshd::common
class nebula::profile::networking::sshd::common {
  stdlib::ensure_packages('openssh-server')

  service { 'ssh':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    require    => Package['openssh-server'],
  }
}
