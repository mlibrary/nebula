# Copyright (c) 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
#
# nebula::profile::notesalexp
#
# Installs Tesseract from Official repositories.
class nebula::profile::tesseract (
) {
  apt::source { 'tesseract':
    source_format => 'sources',
    location      => ['https://notesalexp.org/debian/bullseye/'],
    release       => 'bullseye',
    repos         => ['main'],
    architecture  => $facts['os']['architecture'],
    keyring       => '/etc/apt/keyrings/tesseract-notesalexp.org.asc',
  }

  apt::keyring { 'tesseract-notesalexp.org.asc':
    source => 'puppet:///modules/nebula/apt/keyrings/tesseract-notesalexp.org.asc',
  }

  package { 'tesseract-ocr':
    require => Apt::Source['tesseract'],
  }

  package { 'tesseract for modern Greek':
    name    => 'tesseract-ocr-ell',
    require => Package['tesseract-ocr'],
  }
}
