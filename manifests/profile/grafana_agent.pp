# nebula::profile::grafana_agent
#
# Install grafana agent in flow mode
#
# Based on sample code at
# https://grafana.com/docs/agent/latest/flow/get-started/install/puppet/
#
# @example
#   include nebula::profile::grafana_agent
#
class nebula::profile::grafana_agent () {
  case $::os['family'] {
    'debian': {
      apt::source { 'grafana':
        location => 'https://apt.grafana.com/',
        release  => '',
        repos    => 'stable main',
        key      => {
          id     => 'B53AE77BADB630A683046005963FA27710458545',
          source => 'https://apt.grafana.com/gpg.key',
        },
        before   => Package['grafana-agent-flow'],
      }
      package { 'grafana-agent-flow':
        require => Exec['apt_update'],
        notify  => Service['grafana-agent-flow'],
      }
      service { 'grafana-agent-flow':
        ensure => running,
        name   => 'grafana-agent-flow',
        enable => true,
      }
    }
    default: {
      fail("Unsupported OS family: (${$::os['family']})")
    }
  }
}
