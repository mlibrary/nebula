# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::php
#
# Install php dependencies for HathiTrust applications
#
# @example
#   include nebula::profile::hathitrust::php
class nebula::profile::hathitrust::php () {
  include nebula::profile::hathitrust::apache
  include nebula::profile::geoip

  package {
    [
      'php5-cli',
      'php5-common',
      'php5-curl',
      'php5-gd',
      'php5-geoip',
      'php5-ldap',
      'php5-mysqlnd',
      'php5-xsl',
      'php-date',
      'php-db',
      'php-http-request',
      'php-log',
      'php-mail',
      'php-mdb2',
      'php-net-smtp',
      'php-net-url2',
      'php-pager',
      'php-pear',
      'php-xml-parser',
      'php-xml-serializer',
      'libapache2-mod-php5',
      'pear-horde-channel'
    ]:
  }

}
