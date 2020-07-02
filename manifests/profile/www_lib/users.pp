# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::www_lib::users {
  nebula::usergroup { 'libstaff': }
  nebula::usergroup { 'mpub': }
}
