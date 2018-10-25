# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Work around puppet's bug
#
# When adding code here, definitely explain the related bug, in part so
# we know when we can safely remove the workaround from here.
class nebula::profile::work_around_puppet_bugs (
  String $state_yaml_path,
  String $state_yaml_max_size,
) {
  # Tracked: https://tickets.puppetlabs.com/browse/PUP-3647
  #
  # This was allegedly fixed in puppet 5.5.7, so we should be able to
  # delete this once we aren't running any older versions of puppet.
  #
  # The bug is that the state.yaml file tracks every resource the agent
  # has ever seen, even if it only existed, say, as part of a tidy
  # resource saying to delete the file. So this file can get bloated on
  # servers that do a lot of tidying.
  #
  # When state.yaml gets too big, it starts taking a long time (e.g.
  # sometimes over 35 minutes) for agents to perform what should be a
  # 10-second sync with the master.
  #
  # However, it's safe to delete the file, and this will always delete
  # the file once it reaches a particular size, defaulting to 10M. On
  # most servers, it won't grow past 50K, so this is unlikely to affect
  # most servers.
  tidy { $state_yaml_path:
    size => $state_yaml_max_size,
  }
}
