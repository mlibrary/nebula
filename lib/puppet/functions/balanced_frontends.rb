# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

Puppet::Functions.create_function(:balanced_frontends) do
  dispatch :balanced_frontends do
    return_type 'Hash[String,Array[String]]'
  end

  def frontends
    call_function('puppetdb_query', ['from', 'resources',
                                     ['extract', ['title'],
                                      ['=', 'type', 'Nebula::Balanced_frontend']]])
      .map { |resource| resource['title'] }
      .uniq
  end

  def nodes(frontend)
    scope = closure_scope
    call_function('puppetdb_query', ['from', 'resources',
                                     ['extract', ['certname'],
                                      ['and', ['=', 'type', 'Nebula::Balanced_frontend'],
                                       ['=', 'title', frontend]]]])
      .map { |resource| resource['certname'] }
      .select { |node| call_function('fact_for', node, 'datacenter') == scope['facts']['datacenter'] }
  end

  def balanced_frontends
    frontends
      .map { |frontend| [frontend, nodes(frontend)] }
      .to_h
      .reject { |_frontend, servers| servers.empty? }
  end
end
