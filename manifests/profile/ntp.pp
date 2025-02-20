# nebula::profile::ntp
#
# Manage ntp settings.
#
# @param pools List of ntp pools to use
# @param servers List of ntp servers to use
#
# @example
#   include nebula::profile::ntp
class nebula::profile::ntp (
  Optional[Array[String[1]]] $pools = undef,
  Optional[Array[String[1]]] $servers = undef,
) {
  ensure_packages(
    [
      'ntp',
      'ntpsec',
      'sntp',
      'ntpstat',
      'systemd-timesyncd',
    ],
    { ensure => purged }
  )

  package { 'chrony': }

  service { 'chrony':
    ensure  => 'running',
    enable  => true,
    require => Package['chrony'],
  }

  file { '/etc/chrony/chrony.conf':
    source  => 'puppet:///modules/nebula/chrony/chrony.conf',
    notify  => Service['chrony'],
    require => Package['chrony'],
  }

  # aws ntp servers smear leap seconds for us, so we need
  # to disable chrony's leap second handling
  unless fact('cloud.provider') == 'aws' {
    file { '/etc/chrony/conf.d/leapsectz.conf':
      source  => 'puppet:///modules/nebula/chrony/leapsectz.conf',
      notify  => Service['chrony'],
      require => Package['chrony'],
    }
  }

  if $pools and size($pools) > 0 {
    file { '/etc/chrony/sources.d/local-pools.sources':
      content => $pools.map |$x| { "pool ${x} iburst\n" }.join,
      notify  => Service['chrony'],
      require => Package['chrony'],
    }
  }

  if $servers and size($servers) > 0 {
    file { '/etc/chrony/sources.d/local-servers.sources':
      content => $servers.map |$x| { "server ${x} iburst\n" }.join,
      notify  => Service['chrony'],
      require => Package['chrony'],
    }
  }

  file { default:
    ensure  => directory,
    recurse => true,
    purge   => true,
    ignore  => 'README',
    notify  => Service['chrony'],
    require => Package['chrony'],
    ;
    '/etc/chrony/conf.d/': ;
    '/etc/chrony/sources.d/': ;
  }
}
