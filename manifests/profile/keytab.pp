# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::keytab
#
# Manage SSH
#
# @param default_keytab Path to fallback keytab file
# @param keytab Path to desired keytab file
# @param keytab_source File source value for keytab (to avoid sending
#
# @example
#   include nebula::profile::keytab
class nebula::profile::keytab (
  String  $default_keytab,
  String  $keytab,
  String  $keytab_source,
) {
  $keytab_content = file($keytab, $default_keytab)

  if $keytab_content == '' {
    include nebula::profile::sshd
  } else {
    class { 'nebula::profile::sshd':
      gssapi_auth => true,
    }

    if $keytab_source == '' {
      file { '/etc/krb5.keytab':
        content => $keytab_content,
        mode    => '0600',
      }
    } else {
      file { '/etc/krb5.keytab':
        source => $keytab_source,
        mode   => '0600',
      }
    }
  }
}
