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
    location => $location,
    release  => '/',
    repos    => '',
    key      => {
      'name'   => 'k8s.io.asc',
      'source' => 'puppet:///modules/nebula/apt/keyrings/k8s.io.asc',
    },
  }
}
