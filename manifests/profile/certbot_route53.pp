# Copyright (c) 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# @param certs domains/certificates with haproxy services; wildcard implicitly added
#        example: "quod": { "somejournal.org": ["san-for-journal.org"] }
# @param simple_certs domains/certificates for standalone hosts; no implicit wildcard
#        example: "somedomain.org": ["san-for-domain.org","*.somedomain.org"]
class nebula::profile::certbot_route53 (
  Hash[String, Hash[String, Array[String]]] $certs = {},
  Hash[String, Array[String]] $simple_certs = {},
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
      concat { "${cert_dir}/${main_domain}.crt":
        group  => "puppet",
      }

      concat { "${cert_dir}/${main_domain}.key":
        group  => "puppet",
      }

      concat { "${haproxy_cert_dir}/${service}/${main_domain}.pem":
        group => "puppet",
      }

      concat_fragment { "${main_domain}.crt cert":
        target => "${cert_dir}/${main_domain}.crt",
        source => "/etc/letsencrypt/live/${main_domain}/fullchain.pem"
      }

      concat_fragment { "${main_domain}.key key":
        target => "${cert_dir}/${main_domain}.key",
        source => "/etc/letsencrypt/live/${main_domain}/privkey.pem"
      }

      concat_fragment { "${main_domain}.pem cert":
        order  => "01",
        target => "${haproxy_cert_dir}/${service}/${main_domain}.pem",
        source => "/etc/letsencrypt/live/${main_domain}/fullchain.pem"
      }

      concat_fragment { "${main_domain}.pem key":
        order  => "02",
        target => "${haproxy_cert_dir}/${service}/${main_domain}.pem",
        source => "/etc/letsencrypt/live/${main_domain}/privkey.pem"
      }
    }
  }

  $simple_certs.each |$domain, $sans| {
    file { "${cert_dir}/${domain}.crt":
      source => "/etc/letsencrypt/live/${domain}/fullchain.pem"
    }

    file { "${cert_dir}/${domain}.key":
      source => "/etc/letsencrypt/live/${domain}/privkey.pem"
    }
  }
}
