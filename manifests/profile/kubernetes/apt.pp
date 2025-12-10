# nebula::profile::apt
#
# install kubernets apt source
#
# @example
#   include nebula::profile::apt
class nebula::profile::kubernetes::apt (
  String $location,
) {
  apt::source { 'kubernetes':
    source_format => 'sources',
    location      => [$location],
    release       => '/',
    repos         => ['main'],
    keyring       => '/etc/apt/keyrings/k8s.io.asc',
  }

  apt::keyring { 'k8s.io.asc':
    source => 'puppet:///modules/nebula/apt/keyrings/k8s.io.asc',
  }
}
