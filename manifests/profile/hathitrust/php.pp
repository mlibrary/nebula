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
      'php-geoip', # PECL
      'php7.0-ldap',
      'php7.0-mysql',
      'php7.0-xsl',
      'php-pear',
      'libapache2-mod-php7.0',
      'pear-channels'
    ]:
  }

  class { '::php':
    ensure => present,     # Don't touch stuff from above; should be equivalent
    manage_repos => false, # Set true to add dotdeb repos
    fpm => false,          # We only use mod_php at present
    dev => false,          # Extensions are only added by PECL debs for now
    composer => false,     # System-wide composer seems iffy unless using dotdeb
    pear => true,          # We're using this for PEAR, so set to true
    phpunit => true,       # Unsure whether this should be system or app-level

    extensions => {
      Archive_Tar:           { ensure => '1.4.3',   package_prefix => '', provider => 'pear' },
      Console_Getopt:        { ensure => '1.4.1',   package_prefix => '', provider => 'pear' },
      DB:                    { ensure => '1.7.14',  package_prefix => '', provider => 'pear' },
      DB_DataObject:         { ensure => '1.11.2',  package_prefix => '', provider => 'pear' },
      Date:                  { ensure => '1.4.7',   package_prefix => '', provider => 'pear' },
      File_MARC:             { ensure => '1.1.1',   package_prefix => '', provider => 'pear' },
      HTTP_Request:          { ensure => '1.4.4',   package_prefix => '', provider => 'pear' },
      HTTP_Request2:         { ensure => '2.2.0',   package_prefix => '', provider => 'pear' },
      HTTP_Session2:         { ensure => '0.7.3',   package_prefix => '', provider => 'pear' },
      Log:                   { ensure => '1.12.8',  package_prefix => '', provider => 'pear' },
      MDB2:                  { ensure => '2.5.0b5', package_prefix => '', provider => 'pear' },
      MDB2_Driver_mysql:     { ensure => '1.4.1',   package_prefix => '', provider => 'pear' },
      Mail:                  { ensure => '1.2.0',   package_prefix => '', provider => 'pear' },
      Net_SMTP:              { ensure => '1.6.2',   package_prefix => '', provider => 'pear' },
      Net_Socket:            { ensure => '1.0.14',  package_prefix => '', provider => 'pear' },
      Net_URL:               { ensure => '1.0.15',  package_prefix => '', provider => 'pear' },
      Net_URL2:              { ensure => '2.0.7',   package_prefix => '', provider => 'pear' },
      PEAR:                  { ensure => '1.10.5',  package_prefix => '', provider => 'pear' },
      Pager:                 { ensure => '2.4.8',   package_prefix => '', provider => 'pear' },
      PhpDocumentor:         { ensure => '1.4.4',   package_prefix => '', provider => 'pear' },
      Structures_DataGrid:   { ensure => '0.9.3',   package_prefix => '', provider => 'pear' },
      Structures_Graph:      { ensure => '1.1.1',   package_prefix => '', provider => 'pear' },
      Structures_LinkedList: { ensure => '0.2.2',   package_prefix => '', provider => 'pear' },
      XML_Parser:            { ensure => '1.3.4',   package_prefix => '', provider => 'pear' },
      XML_Serializer:        { ensure => '0.20.2',  package_prefix => '', provider => 'pear' },
      XML_Util:              { ensure => '1.4.2',   package_prefix => '', provider => 'pear' },
    },
  }
}
