# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::quod::dependencies::perl
#
# Install perl dependencies for quod applications. These are packages
# and settings common to all quod environments.
#
# @example
#   include nebula::profile::quod::dependencies::perl
class nebula::profile::quod::dependencies::perl () {
  include nebula::profile::quod::dependencies::packages

  package { [
    'libalgorithm-c3-perl',
    'libalgorithm-diff-perl',
    'libalgorithm-diff-xs-perl',
    'libalgorithm-merge-perl',
    'libapache-session-perl',
    'libappconfig-perl',
    'libarchive-zip-perl',
    'libauthen-sasl-perl',
    'libbareword-filehandles-perl',
    'libb-hooks-endofscope-perl',
    'libb-hooks-op-check-perl',
    'libbit-vector-perl',
    'libcaptcha-recaptcha-perl',
    'libcapture-tiny-perl',
    'libcarp-clan-perl',
    'libcgi-compile-perl',
    'libcgi-emulate-psgi-perl',
    'libcgi-pm-perl',
    'libclass-accessor-perl',
    'libclass-c3-perl',
    'libclass-c3-xs-perl',
    'libclass-isa-perl',
    'libclass-load-perl',
    'libclass-load-xs-perl',
    'libclass-method-modifiers-perl',
    'libclass-std-perl',
    'libclass-tiny-perl',
    'libclass-xsaccessor-perl',
    'libcommon-sense-perl',
    'libconfig-auto-perl',
    'libconfig-inifiles-perl',
    'libconfig-std-perl',
    'libconvert-asn1-perl',
    'libconvert-binhex-perl',
    'libcrypt-rc4-perl',
    'libdata-optlist-perl',
    'libdata-validate-domain-perl',
    'libdate-calc-perl',
    'libdate-calc-xs-perl',
    'libdate-manip-perl',
    'libdbd-mysql-perl',
    'libdbd-sqlite3-perl',
    'libdbi-perl',
    'libdevel-caller-perl',
    'libdevel-globaldestruction-perl',
    'libdevel-lexalias-perl',
    'libdevel-partialdump-perl',
    'libdevel-stacktrace-perl',
    'libdist-checkconflicts-perl',
    'libdpkg-perl',
    'libemail-abstract-perl',
    'libemail-address-perl',
    'libemail-date-format-perl',
    'libemail-sender-perl',
    'libemail-simple-perl',
    'libencode-locale-perl',
    'liberror-perl',
    'libeval-closure-perl',
    'libfile-copy-recursive-perl',
    'libfile-fcntllock-perl',
    'libfile-find-rule-perl',
    'libfile-listing-perl',
    'libfile-pushd-perl',
    'libfile-slurp-perl',
    'libfont-afm-perl',
    'libfont-freetype-perl',
    'libgeo-ip-perl',
    'libgssapi-perl',
    'libhtml-format-perl',
    'libhtml-form-perl',
    'libhtml-parser-perl',
    'libhtml-tagset-perl',
    'libhtml-template-perl',
    'libhtml-tiny-perl',
    'libhtml-tree-perl',
    'libhttp-cookies-perl',
    'libhttp-daemon-perl',
    'libhttp-date-perl',
    'libhttp-message-perl',
    'libhttp-negotiate-perl',
    'libimage-exiftool-perl',
    'libimage-magick-perl',
    'libimage-magick-q16-perl',
    'libimage-size-perl',
    'libimport-into-perl',
    'libindirect-perl',
    'libintl-perl',
    'libio-html-perl',
    'libio-pty-perl',
    'libio-socket-ip-perl',
    'libio-socket-ssl-perl',
    'libio-string-perl',
    'libio-stringy-perl',
    'libipc-run-perl',
    'libjson-xs-perl',
    'liblexical-sealrequirehints-perl',
    'liblist-compare-perl',
    'liblist-moreutils-perl',
    'liblocale-gettext-perl',
    'liblwp-mediatypes-perl',
    'liblwp-protocol-https-perl',
    'libmail-sendmail-perl',
    'libmailtools-perl',
    'libmarc-record-perl',
    'libmath-round-perl',
    'libmime-tools-perl',
    'libmime-types-perl',
    'libmodule-implementation-perl',
    'libmodule-pluggable-perl',
    'libmodule-runtime-conflicts-perl',
    'libmodule-runtime-perl',
    'libmoo-perl',
    'libmoose-perl',
    'libmoox-types-mooselike-perl',
    'libmp3-info-perl',
    'libmro-compat-perl',
    'libmultidimensional-perl',
    'libnamespace-clean-perl',
    'libnet-daemon-perl',
    'libnet-domain-tld-perl',
    'libnet-http-perl',
    'libnet-ldap-perl',
    'libnet-smtp-ssl-perl',
    'libnet-ssleay-perl',
    'libnet-z3950-zoom-perl',
    'libnumber-compare-perl',
    'libole-storage-lite-perl',
    'libpackage-deprecationmanager-perl',
    'libpackage-stash-perl',
    'libpackage-stash-xs-perl',
    'libpadwalker-perl',
    'libparams-classify-perl',
    'libparams-util-perl',
    'libparse-recdescent-perl',
    'libperl4-corelibs-perl',
    'librole-tiny-perl',
    'libsocket-perl',
    'libspreadsheet-writeexcel-perl',
    'libstrictures-perl',
    'libsub-exporter-perl',
    'libsub-exporter-progressive-perl',
    'libsub-identify-perl',
    'libsub-install-perl',
    'libsub-name-perl',
    'libswitch-perl',
    'libsys-hostname-long-perl',
    'libtask-weaken-perl',
    'libtemplate-perl',
    'libterm-readkey-perl',
    'libtest-nowarnings-perl',
    'libtest-requires-perl',
    'libtext-charwidth-perl',
    'libtext-csv-xs-perl',
    'libtext-glob-perl',
    'libtext-iconv-perl',
    'libtext-unidecode-perl',
    'libtext-wrapi18n-perl',
    'libthrowable-perl',
    'libtimedate-perl',
    'libtry-tiny-perl',
    'libunicode-string-perl',
    'liburi-perl',
    'libuuid-perl',
    'libuuid-tiny-perl',
    'libvariable-magic-perl',
    'libwww-perl',
    'libwww-robotrules-perl',
    'libxml-libxml-perl',
    'libxml-libxslt-perl',
    'libxml-namespacesupport-perl',
    'libxml-parser-perl',
    'libxml-sax-base-perl',
    'libxml-sax-expat-perl',
    'libxml-sax-perl',
    'libxml-simple-perl',
    'libxml-writer-perl',
    'libyaml-perl',
    'libyaml-syck-perl',
    'perlmagick']:
  }

  -> nebula::cpan { [
    'Algorithm::LUHN',
    'Captcha::reCAPTCHA',
    'DBD::Oracle',
    'Domain::PublicSuffix',
    'File::ANVL',
    'File::Namaste',
    'File::Pairtree',
    'File::Value',
    'IP::Geolocation::MMDB',
    'Mail::Sender',
    'Net::IDN::Encode',
    'OAuth::Lite']:
  }

  file { '/etc/profile.d/perl-include.sh':
    ensure  => 'file',
    content => template('nebula/profile/quod/etc/profile.d/perl-include.sh.erb'),
  }
}
