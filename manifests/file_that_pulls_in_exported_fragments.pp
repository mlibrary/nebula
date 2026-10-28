# Copyright (c) 2026 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

define nebula::file_that_pulls_in_exported_fragments (
  String $fragment_tag,
) {
  concat { $title:
  }

  Concat::Fragment <<| tag == $fragment_tag |>>
}
