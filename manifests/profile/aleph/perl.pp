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
    'libjson-perl',
    'libmarc-record-perl',
    'libmarc-file-mij-perl',
    'libnet-ldap-perl',
    'libsms-send-perl',
    'libspreadsheet-parseexcel-perl',
    'libspreadsheet-writeexcel-perl',
    'libspreadsheet-xlsx-perl',
  ])

  nebula::cpan { [
    'MARC::File::XML',
    'Net::Z3950::ZOOM',
    'XML::LibXML',
    'Mail::DWIM',
    'File::MMagic',
    'MIME::Lite',
    'Dotenv',
    'SMS::Send::Twilio']:
  }
}
