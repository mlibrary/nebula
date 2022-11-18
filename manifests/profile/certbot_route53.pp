# Copyright (c) 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::certbot_route53 (
  Hash[String, Hash[String, Array[String]]] $certs = {},
  String $cert_dir = "/var/local/cert_dir",
  String $haproxy_cert_dir = "/var/local/haproxy_cert_dir",
  String $letsencrypt_email = "nope@nope.zone",
  String $aws_access_key_id = "default.invalid",
  String $aws_secret_access_key = "default.invalid",
) {
  ensure_packages([
    "certbot",
    "awscli",
    "python3-certbot-dns-route53",
  ])

  file { "/root/.aws":
    ensure => "directory"
  }

  file { "/root/.aws/config":
    mode    => "0600",
    content => "[default]\nregion = us-east-1\n"
  }

  file { "/root/.aws/credentials":
    mode    => "0600",
    content => template("nebula/profile/certbot_route53/credentials.ini.erb")
  }

  file { "/tmp/all_cert_commands":
    content => template("nebula/profile/certbot_route53/commands.erb")
  }

  $certs.each |$service, $domains| {
    $domains.each |$main_domain, $alt_domains| {
      $all_domains = [$main_domain] + $alt_domains

      $all_domains.each |$domain| {
        concat { "${cert_dir}/${domain}.crt":
          group  => "puppet",
        }

        concat { "${cert_dir}/${domain}.key":
          group  => "puppet",
        }

        concat { "${haproxy_cert_dir}/${service}/${domain}.pem":
          group => "puppet",
        }

        concat_fragment { "${domain}.crt cert":
          target => "${cert_dir}/${domain}.crt",
          source => "/etc/letsencrypt/live/${domain}/fullchain.pem"
        }

        concat_fragment { "${domain}.key key":
          target => "${cert_dir}/${domain}.key",
          source => "/etc/letsencrypt/live/${domain}/privkey.pem"
        }

        concat_fragment { "${domain}.pem cert":
          order  => "01",
          target => "${haproxy_cert_dir}/${service}/${domain}.pem",
          source => "/etc/letsencrypt/live/${domain}/fullchain.pem"
        }

        concat_fragment { "${domain}.pem key":
          order  => "02",
          target => "${haproxy_cert_dir}/${service}/${domain}.pem",
          source => "/etc/letsencrypt/live/${domain}/privkey.pem"
        }
      }
    }
  }
}
