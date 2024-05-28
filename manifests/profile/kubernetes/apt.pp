# nebula::profile::apt
#
# install kubernets apt source
#
# @example
#   include nebula::profile::apt
#
#   nebula::profile::kubernetes::apt::location: "https://pkgs.k8s.io/core:/stable:/v1.29/deb/"
class nebula::profile::kubernetes::apt (
  String $location,
) {
  apt::source { 'kubernetes':
    location => $location,
    release  => '/',
    repos    => '',
    # per https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
    # this key does not change for new releases. This will only need to change
    # if the listed version is removed from the deb server.
    key      => {
      'name'   => 'k8s.io.asc',
      'source' => 'https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key',
    },
  }
}
