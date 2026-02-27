# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::taghosts::index (
  Hash[String, Array[String]] $static_hosts = {},
  Array[String] $known_domains = [],
) {
  Concat::Fragment <<| tag == 'taghosts' |>>

  concat { '/var/lib/ae/active-servers':
    owner   => 'root',
    mode    => '0644',
    require => File['/var/lib/ae'],
  }

  $static_hosts.each |$host, $tags| {
    # Each line starts with the host, a tab, and the tag "static" to
    # show this host's tags are statically managed in hieradata.
    concat::fragment { "taghosts ${host} 000":
      target  => '/var/lib/ae/active-servers',
      content => "${host}\tstatic",
    }

    $tags.each |$i, $tag| {
      $order = sprintf('%<i>03d', { 'i' => ($i + 1) })
      concat::fragment { "taghosts ${host} ${order} ${tag}":
        target  => '/var/lib/ae/active-servers',
        content => " ${tag}",
      }
    }

    # Each line ends with a newline.
    concat::fragment { "taghosts ${host} 999":
      target  => '/var/lib/ae/active-servers',
      content => "\n",
    }
  }

  file { '/var/lib/ae':
    ensure => 'directory',
    owner  => 'root',
    mode   => '0755',
  }

  file { '/usr/local/bin/taghosts':
    owner   => 'root',
    mode    => '0755',
    content => template('nebula/profile/taghosts/taghosts.sh.erb'),
  }

  file { '/etc/bash_completion.d/_taghosts':
    owner   => 'root',
    mode    => '0755',
    content => template('nebula/profile/taghosts/bash_completion.erb'),
  }

  file { '/usr/local/share/zsh/site-functions/_taghosts':
    owner   => 'root',
    mode    => '0755',
    content => template('nebula/profile/taghosts/zsh_completion.erb'),
  }

  file { '/usr/local/bin/exechosts':
    owner   => 'root',
    mode    => '0755',
    content => template('nebula/profile/taghosts/exechosts.sh.erb'),
  }
}
