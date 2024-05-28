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
    location     => 'https://notesalexp.org/debian/bullseye/',
    key          =>  {
      name   => 'tesseract-notesalexp.org.asc',
      source => 'https://notesalexp.org/debian/alexp_key.asc'
    },
    release      => 'bullseye',
    repos        => 'main',
    architecture => $::os['architecture'],
  }

  package { 'tesseract-ocr':
    require => Apt::Source['tesseract'],
  }

}
