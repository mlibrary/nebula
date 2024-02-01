class nebula::profile::kubernetes::apt {
  apt::source { 'kubernetes':
    location => 'https://pkgs.k8s.io/core:/stable:/v1.28/deb/',
    release  => '/',
    repos    => '',
    key      => {
      'id'     => 'DE15B14486CD377B9E876E1A234654DA9A296436',
      'source' => 'https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key',
    },
  }
}
