# Copyright (c) 2023 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::authz_test {
  include nebula::profile::apache
  include nebula::profile::apache::authz_umichlib

  ensure_packages(['libjson-xs-perl'])
  nebula::cpan { ['CGI']: }
  Package <| |> -> Nebula::Cpan <| |>

}
