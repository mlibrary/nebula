# Copyright (c) 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
#
# nebula::profile::notesalexp
#
# Installs Tesseract from Official repositories.
class nebula::profile::tesseract {
  stdlib::ensure_packages([
    'tesseract-ocr',
    'tesseract-ocr-ell', # tesseract for modern Greek
  ])
}
