# Copyright (c) 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
#
# nebula::profile::notesalexp
#
# Installs Tesseract from Official repositories.
class nebula::profile::notesalexp (
) {

  apt::source { 'notesalexp':
    location     => 'https://notesalexp.org/tesseract-ocr5',
    key          =>  {
      id     => '882DCDF8BE9972B21933BA8282F409933771AC78',
      source => 'https://notesalexp.org/debian/alexp_key.asc'
    },
    release      => 'stable',
    repos        => 'main',
    architecture => $::os['architecture'],
  }

  package { 'tesseract-ocr':
    require => Apt::Source['notesalexp'],
  }

}
