# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::quod::prod::perl
#
# Install perl dependencies for quod applications. These packages
# and settings are unique to the prod  environments.
#
# @example
#   include nebula::profile::quod::prod::perl
class nebula::profile::quod::prod::perl () {
  require nebula::profile::quod::dependencies::perl

  package { [
    'libmime-base32-perl',
    'libarchive-extract-perl',
    'libcgi-fast-perl',
    'libcrypt-ssleay-perl',
    'libdata-section-perl',
    'libfcgi-perl',
    'liblog-message-perl',
    'liblog-message-simple-perl',
    'libmodule-build-perl',
    'libmodule-signature-perl',
    'libpackage-constants-perl',
    'libpod-latex-perl',
    'libpod-readme-perl',
    'libregexp-common-perl',
    'libsoftware-license-perl',
    'libterm-ui-perl',
    'libtest-simple-perl',
    'libtext-soundex-perl',
    'libtext-template-perl']:
  }

  -> nebula::cpan { [
    'Class::Data::Accessor',
    'Class::ErrorHandler',
    'Crypt::OpenSSL::Random',
    'Crypt::OpenSSL::RSA',
    'UNIVERSAL::require']:
  }
}
