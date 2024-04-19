# nebula::profile::loki
#
# Install grafana alloy, configure to send logs to loki
#
# @example
#   include nebula::profile::loki
#
#   class { 'nebula::profile::loki':
#     log_files => {
#       # service name becomes a tag in loki
#       "service_name" => ["/path/to/log/file.log","/another/log/path.log"]
#     }
#   }
#
#   class { 'nebula::profile::loki':
#     log_files => {
#       "apache" => ["/var/log/apache.log", "/var/log/apache.err"],
#       "solr" => ["/var/log/solr.log"],
#     }
#   }
#
#
class nebula::profile::loki (
  String $loki_endpoint_url = 'https://loki-gateway.loki/loki/api/v1/push',
  Hash[String, Array[String]] $log_files = {},
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
    '/etc/alloy/config.alloy':
      owner   => 'root',
      content => template("nebula/profile/loki/config.alloy.erb")
  }
}
