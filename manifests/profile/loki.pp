# nebula::profile::loki
#
# Install grafana alloy, configure to send logs to loki
#
# @example
#   include nebula::profile::loki
#
class nebula::profile::loki (
  String $endpoint_url = 'https://loki-gateway.loki/loki/api/v1/push',
){
  $certname = $trusted['certname']
  $hostname = $trusted['hostname']
  $user = 'alloy'
  $home = '/var/lib/alloy'
  $group = 'alloy'

  apt::source { 'grafana':
    location => 'https://apt.grafana.com/',
    release  => '',
    repos    => 'stable main',
    key      => {
      name   => 'grafana.asc',
      source => 'https://apt.grafana.com/gpg.key',
    },
  }

  package { 'alloy':
    require => Apt::Source['grafana'],
    notify  => Service['alloy'],
  }
  service { 'alloy':
    ensure => running,
    name   => 'alloy',
    enable => true,
  }

  file {
    default:
      owner   => $user,
      group   => $group,
      mode    => '0644',
      require => Package['alloy'],
      notify  => Service['alloy'],
    ;
    "${home}/crt.pem":
      source => "/etc/puppetlabs/puppet/ssl/certs/${certname}.pem",
    ;
    "${home}/crt.key":
      source => "/etc/puppetlabs/puppet/ssl/private_keys/${certname}.pem",
      mode   => '0600',
    ;
  }

  file {
    default:
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['alloy'],
      notify  => Service['alloy'],
    ;
    '/etc/alloy':
      ensure => 'directory',
      mode   => '0755',
    ;
    '/etc/alloy/config.alloy':
      content => template("nebula/profile/loki/config.alloy.erb"),
    ;
    '/etc/default/alloy':
      content => template("nebula/profile/loki/alloy.env.erb"),
  }
}
