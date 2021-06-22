
# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::aleph::perl
#
# Install perl dependencies for aleph/makersmark applications
#
# @example
#   include nebula::profile::aleph::perl
class nebula::profile::aleph::perl () {

  ensure_packages([
    'libsms-send-perl',
    'libjson-perl',
    'libnet-ldap-perl',
    'libmarc-record-perl',
    'libmarc-file-mij-perl',
    'libspreadsheet-parseexcel-perl',
    'libspreadsheet-writeexcel-perl',
    'libspreadsheet-xlsx-perl',
  ])

  nebula::cpan { [
    'MARC::File::XML',
    'SMS::Send::Twilio']:
  }

}
