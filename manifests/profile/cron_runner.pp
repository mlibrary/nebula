# Copyright (c) 2023 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::cron_runner (
  Hash $crons = {}
) {
  nebula::usergroup { 'cron': }
  User <| title == 'spot' |>
  create_resources('cron', $crons)
}
