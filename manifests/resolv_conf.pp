class nebula::resolv_conf (
  Array[String] $nameservers,
  Array[String] $searchpath = [],
  String        $mode = '0644',
){
  # replicate behavior of saz/resolv_conf for Debian based OS
  package { 'resolvconf':
    ensure => absent
  }

  file { '/etc/resolv.conf':
    owner   => 'root',
    group   => 'root',
    mode    => $mode,
    content => template("nebula/resolv_conf/resolv.conf.erb"),
  }
}
