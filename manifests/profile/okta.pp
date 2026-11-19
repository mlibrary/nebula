class nebula::profile::okta {
  package { 'pam-okta': }

  concat_fragment { '/etc/pam.d/sshd: pam_okta':
    target  => '/etc/pam.d/sshd',
    content => @("EOT")

      # Require Okta 2FA for password logins; public-key bypasses PAM
      auth required pam_okta.so
      | EOT
  }
}
