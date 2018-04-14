# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::puppet::query' do
  def contain_puppet_query
    contain_file('/usr/local/sbin/puppet-query')
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to contain_package('curl') }

      it { is_expected.to contain_puppet_query.with_mode('0755') }

      [
        %r{^#!/bin/sh$},
        %r{^exec curl -X POST --tlsv1},
        %r{puppetdb\.default\.invalid:8081/pdb/query/v4/resources},
        %r{--cacert /etc/puppetlabs/puppet/ssl/certs/ca\.pem},
        %r{--cert /etc/puppetlabs/puppet/ssl/certs/[^/]+\.pem},
        %r{--key /etc/puppetlabs/puppet/ssl/private_keys/[^/]+\.pem},
        %r{-H 'Content-Type:application/json'},
        %r{-d "\$@"},
      ].each do |line|
        it { is_expected.to contain_puppet_query.with_content(line) }
      end
    end
  end
end
