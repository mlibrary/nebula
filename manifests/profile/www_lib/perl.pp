
# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::www_lib::perl
#
# Install perl dependencies for www.lib applications
#
# @example
#   include nebula::profile::www_lib::perl
class nebula::profile::www_lib::perl () {
  include nebula::profile::www_lib::dependencies
  include nebula::profile::geoip

  ensure_packages([
    'libalgorithm-c3-perl',
    'libany-moose-perl',
    'libcapture-tiny-perl',
    'libclass-accessor-chained-perl',
    'libclass-accessor-perl',
    'libclass-c3-perl',
    'libclass-c3-xs-perl',
    'libclass-isa-perl',
    'libclass-method-modifiers-perl',
    'libcommon-sense-perl',
    'libconvert-asn1-perl',
    'libcrypt-gpg-perl',
    'libcrypt-hcesha-perl',
    'libdancer-perl',
    'libdata-page-perl',
    'libdata-pageset-perl',
    'libdata-section-simple-perl',
    'libdate-manip-perl',
    'libdbd-mysql-perl',
    'libdbd-oracle-perl',
    'libdbi-perl',
    'libdbix-class-perl',
    'libdigest-sha-perl',
    'libdpkg-perl',
    'libencode-locale-perl',
    'liberror-perl',
    'libexcel-writer-xlsx-perl',
    'libextutils-config-perl',
    'libextutils-helpers-perl',
    'libextutils-installpaths-perl',
    'libfile-copy-recursive-perl',
    'libfile-fcntllock-perl',
    'libfile-fnmatch-perl',
    'libfile-listing-perl',
    'libfont-afm-perl',
    'libgeo-ip-perl',
    'libhtml-form-perl',
    'libhtml-format-perl',
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
    'libhttp-server-simple-perl',
    'libinternals-perl',
    'libio-pty-perl',
    'libio-socket-inet6-perl',
    'libio-socket-ip-perl',
    'libio-socket-ssl-perl',
    'libipc-run-perl',
    'libjson-xs-perl',
    'liblocal-lib-perl',
    'liblocale-gettext-perl',
    'liblwp-mediatypes-perl',
    'liblwp-protocol-https-perl',
    'libmailtools-perl',
    'libmath-bigint-perl',
    'libmouse-perl',
    'libmro-compat-perl',
    'libnet-daemon-perl',
    'libnet-http-perl',
    'libnet-ldap-perl',
    'libnet-ssleay-perl',
    'libparams-classify-perl',
    'libperl4-corelibs-perl',
    'libplack-perl',
    'libsocket-perl',
    'libsocket6-perl',
    'libsub-name-perl',
    'libsub-uplevel-perl',
    'libswitch-perl',
    'libtest-deep-perl',
    'libtest-exception-perl',
    'libtest-fatal-perl',
    'libtest-mockobject-perl',
    'libtest-nowarnings-perl',
    'libtest-requires-perl',
    'libtest-simple-perl',
    'libtest-warn-perl',
    'libtry-tiny-perl',
    'libtext-charwidth-perl',
    'libtext-csv-perl',
    'libtext-csv-xs-perl',
    'libtext-iconv-perl',
    'libtext-wrapi18n-perl',
    'libtimedate-perl',
    'liburi-perl',
    'libuuid-perl',
    'libwebservice-solr-perl',
    'libwww-curl-perl',
    'libwww-mechanize-perl',
    'libwww-perl',
    'libwww-robotrules-perl',
    'libxml-easy-perl',
    'libxml-libxml-perl',
    'libxml-libxslt-perl',
    'libxml-namespacesupport-perl',
    'libxml-parser-perl',
    'libxml-sax-base-perl',
    'libxml-sax-expat-perl',
    'libxml-sax-perl',
    'libxml-xpath-perl',
    'libyaml-perl',
    'libyaml-syck-perl',
  ])

  nebula::cpan { [
    'CGI',
    'Dancer::Template::Haml',
    'Digest::SHA1',
    'Mojolicious', # must pin to version
    'Mojo::Server::FastCGI', # must pin to version
    'Relations',
    'Relations::Query',
    'SQL::Beautify',
    'SQL::Tokenizer',
    'UNIVERSAL::can',
    'UNIVERSAL::isa',
    'WebService::Solr::Tiny']:
  }

  # Install all software before adding any cpan modules.
  Package <| |> -> Nebula::Cpan <| |>

  file { '/etc/profile.d/perl-include.sh':
    ensure  => 'file',
    content => template('nebula/profile/www_lib/etc/profile.d/perl-include.sh.erb'),
  }

}
