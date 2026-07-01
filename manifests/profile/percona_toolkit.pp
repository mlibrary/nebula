# install percona-toolkit
class nebula::profile::percona_toolkit {
  apt::source { 'percona':
    source_format => 'sources',
    comment       => 'percona',
    location      => ['https://repo.percona.com/apt/'],
    repos         => ['testing'],
    keyring       => '/etc/apt/keyrings/percona.asc',
    architecture  => $facts['os']['architecture'],
  }
  apt::keyring { 'percona.asc':
    source => 'puppet:///modules/nebula/apt/keyrings/percona.asc',
  }

  package { 'percona-toolkit':
    require => Apt::Source['percona'],
  }
}
