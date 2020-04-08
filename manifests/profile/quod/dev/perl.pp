# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::quod::dev::perl
#
# Install perl dependencies for quod applications. These packages
# and settings are unique to the dev environment.
#
# @example
#   include nebula::profile::quod::dev::perl
class nebula::profile::quod::dev::perl () {
  require nebula::profile::quod::dependencies::perl

  package { [
    'libany-moose-perl',
    'libapt-pkg-perl',
    'libclass-data-accessor-perl',
    'libclass-data-inheritable-perl',
    'libclass-errorhandler-perl',
    'libclass-singleton-perl',
    'libclone-perl',
    'libconfig-file-perl',
    'libconfig-tiny-perl',
    'libcrypt-openssl-bignum-perl',
    'libcrypt-openssl-random-perl',
    'libcrypt-openssl-rsa-perl',
    'libdatetime-locale-perl',
    'libdatetime-perl',
    'libdatetime-timezone-perl',
    'libdevel-overloadinfo-perl',
    'libdigest-hmac-perl',
    'libemail-messageid-perl',
    'libemail-mime-contenttype-perl',
    'libemail-mime-encodings-perl',
    'libemail-mime-perl',
    'libemail-valid-perl',
    'libexception-class-perl',
    'libexporter-tiny-perl',
    'libfile-basedir-perl',
    'libfile-fnmatch-perl',
    'libfile-homedir-perl',
    'libfile-next-perl',
    'libfile-stripnondeterminism-perl',
    'libfilesys-df-perl',
    'libfile-which-perl',
    'libio-socket-inet6-perl',
    'libipc-shareable-perl',
    'libipc-system-simple-perl',
    'liblist-allutils-perl',
    'liblist-someutils-perl',
    'liblist-utilsby-perl',
    'liblog-dispatch-perl',
    'liblog-log4perl-perl',
    'libmouse-perl',
    'libnamespace-autoclean-perl',
    'libnet-dns-perl',
    'libnet-idn-encode-perl',
    'libnet-ip-perl',
    'libossp-uuid-perl',
    'libparams-validate-perl',
    'libparams-validationcompiler-perl',
    'libparse-debianchangelog-perl',
    'libreadonly-perl',
    'libreadonly-xs-perl',
    'libregexp-assemble-perl',
    'libscalar-list-utils-perl',
    'libsocket6-perl',
    'libsort-naturally-perl',
    'libspecio-perl',
    'libtest-fatal-perl',
    'libtext-levenshtein-perl',
    'libtie-ixhash-perl',
    'libtypes-serialiser-perl',
    'libuniversal-require-perl',
    'libwww-curl-perl',
    'libxml-twig-perl',
    'libxml-xpathengine-perl',
    'libxml-xpath-perl',
    'libyaml-appconfig-perl',
    'libyaml-libyaml-perl',
    'xmlformat-perl']:
  }

  -> nebula::cpan { [
    'Module::Build',
    'Net::IDN::Encode']:
  }
}
