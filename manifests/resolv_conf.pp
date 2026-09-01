class nebula::resolv_conf (
  Array[String] $nameservers,
  Array[String] $searchpath = [],
  String        $mode = '0644',
) {
  # replicate behavior of saz/resolv_conf for Debian based OS
  package { 'resolvconf':
    ensure => absent
  }

  file { '/etc/resolv.conf':
    owner   => 'root',
    group   => 'root',
    mode    => $mode,
    content => template('nebula/resolv_conf/resolv.conf.erb'),
  }

  # we never want systemd-resolved
  # on older Debian releases it's part of systemd, so we can't purge it
  if $facts['os']['distro']['codename'] in ['jammy'] {
    service { 'systemd-resolved':
      ensure => stopped,
      enable => false,
      before => File['/etc/resolv.conf'],
    }
  } else {
    package { 'systemd-resolved':
      ensure => absent,
      before => File['/etc/resolv.conf'],
    }
  }
}
