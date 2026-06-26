# configure mariadb apt repo, install mariadb client
# see https://mariadb.org/download/?t=repo-config for mirror list
class nebula::profile::mariadb (
  String $version = '12.3',
  Optional[String] $apt_mirror = undef,
) {
  $apt_path = "${version}/${facts['os']['name'].downcase()}"
  if $apt_mirror {
    $repos = [
      "${apt_mirror}/mariadb/repo/${apt_path}",
      "https://deb.mariadb.org/${apt_path}"
    ]
  } else {
    $repos = [
      "https://deb.mariadb.org/${apt_path}"
    ]
  }

  apt::source { 'mariadb':
    source_format => 'sources',
    comment       => 'mariadb',
    location      => $repos,
    repos         => ['main'],
    keyring       => '/etc/apt/keyrings/mariadb.asc',
    architecture  => $facts['os']['architecture'],
  }
  apt::keyring { 'mariadb.asc':
    source => 'puppet:///modules/nebula/apt/keyrings/mariadb.asc',
  }

  package { 'mariadb-client':
    require => Apt::Source['mariadb'],
  }
}
