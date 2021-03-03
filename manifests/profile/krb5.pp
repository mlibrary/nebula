# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::krb5
#
# Manage standalone kerberos.
#
# @param realm debconf krb5-config/default_realm
#
# @example
#   include nebula::profile::krb5
class nebula::profile::krb5 (
  String  $realm
) {

  include nebula::profile::networking::keytab

  package { 'krb5-user': }
  package { 'libpam-krb5': }

  debconf { 'krb5-config/default_realm':
    type  => 'string',
    value => $realm,
  }
}
