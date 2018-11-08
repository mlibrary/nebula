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
      'php7.0-cli',
      'php7.0-common',
      'php7.0-curl',
      'php7.0-gd',
      'php-geoip',
      'php7.0-ldap',
      'php7.0-mysql',
      'php7.0-xsl',
      'php-date',
      'php-db',
      'php-http-request',
      'php-log',
      'php-mail',
      'php-mdb2',
      'php-net-smtp',
      'php-net-url2',
      'php-pear',
      'libapache2-mod-php7.0',
      'pear-channels'
    ]:
  }

#      to install via pear
#      'php-pager',
#      'php-xml-parser',
#      'php-xml-serializer',

}
