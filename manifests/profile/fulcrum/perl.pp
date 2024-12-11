# The perl profile is needed for monitor_pl to work, but it pulls in a
# ton of stuff. We should probably allow for different haproxy http checks
# for a service, and eliminate the perl/monitor_pl dependency here.

class nebula::profile::fulcrum::perl (
  Hash $hosts = {}
) {

  include nebula::profile::www_lib::perl

  create_resources('host',$hosts)

  include nebula::profile::www_lib::apache::base
  include nebula::profile::www_lib::apache::fulcrum

  cron {
    default:
      user => 'root',
    ;

    'purge apache access logs 1/2':
      hour    => 1,
      minute  => 7,
      command => '/usr/bin/find /var/log/apache2 -type f -mtime +14 -name "*log*" -exec /bin/rm {} \; > /dev/null 2>&1',
    ;

    'purge apache access logs 2/2':
      hour    => 1,
      minute  => 17,
      command => '/usr/bin/find /var/log/apache2 -type f -mtime +2  -name "*log*" ! -name "*log*gz" -exec /usr/bin/pigz {} \; > /dev/null 2>&1',
      require => Package['pigz'],
    ;
  }

  ensure_packages(['pigz'])

}
