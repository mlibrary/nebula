# nebula::log
#
# Send logs from a service to log server.
# Currently implimented with Alloy and Loki
#
# @example
#
#   nebula::log { 'solr':
#     files => ["/var/log/solr.log"],
#   }
#
#   nebula::log { 'apache':
#       "files" => ["/var/log/apache.log", "/var/log/apache.err"],
#   }
#
define nebula::log (
  String $service = $title,
  Array[String] $files,
){
  include nebula::profile::loki

  file { "/etc/alloy/${service}.alloy":
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['alloy'],
    notify  => Service['alloy'],
    content => template("nebula/profile/loki/drop_in.alloy.erb"),
  }
}
