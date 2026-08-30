# Puppet Server config
#
# @example
#   include nebula::profile::puppet::server
class nebula::profile::puppet::server (
  Array[String] $deploy_keys,
) {
  ensure_packages([
    'g10k',
  ])
  package { 'librarian-puppet':
    provider => gem,
    command  => '/opt/puppetlabs/puppet/bin/gem',
  }

  $g10k_user = 'g10k'
  $g10k_home = "/var/lib/${g10k_user}"
  user { 'g10k':
    ensure     => present,
    comment    => 'g10k daemon user',
    home       => $g10k_home,
    managehome => true,
    system     => true,
    shell      => '/bin/bash',
  }
  $deploy_keys.each |$repo| {
    ssh_keygen { $repo:
      type     => 'ed25519',
      user     => $g10k_user,
      require  => User[$g10k_user],
      filename => "${g10k_home}/.ssh/${repo}",
    }
  }

  file { default:
    ensure  => directory,
    user    => 'g10k',
    group   => 'g10k',
    require => User[$g10k_user],
    ;
    '/etc/puppetlabs/code/': ;
    '/etc/puppetlabs/code/environments/': ;
    '/etc/puppetlabs/code/environments/production/': ;
    '/etc/puppetlabs/code/modules/': ;
  }
}
