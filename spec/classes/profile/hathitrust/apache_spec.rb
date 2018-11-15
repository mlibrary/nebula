
# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'
require_relative '../../../support/contexts/with_mocked_nodes'
require 'pry'

describe 'nebula::profile::hathitrust::apache' do
  def multiline2re(string)
    Regexp.new(string.split("\n").map { |line| Regexp.escape(line.lstrip) }.join('\n\s*'))
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:vhost_config) { 'babel.hathitrust.org ssl-directories' }

      let(:haproxy) { { 'ip' => Faker::Internet.ip_v4_address, 'hostname' => 'haproxy' } }
      let(:rolenode) { { 'ip' => Faker::Internet.ip_v4_address, 'hostname' => 'rolenode' } }

      include_context 'with mocked puppetdb functions', 'somedc', %w[haproxy rolenode], 'nebula::profile::haproxy' => %w[haproxy]

      snippets = [
        <<~EOT,
          <Directory "/htapps/babel/imgsrv/cgi">
            AllowOverride None

            <Files "imgsrv">
              SetHandler proxy:fcgi://127.0.0.1:31028
            </Files>
          </Directory>
        EOT
        <<~EOT
          <DirectoryMatch "^/htapps/babel/([^/]+)/cgi">
            Options +ExecCGI
            SetHandler cgi-script
          </DirectoryMatch>
        EOT
      ]

      snippets.each do |snippet|
        it { is_expected.to contain_concat_fragment(vhost_config).with_content(multiline2re(snippet)) }
      end
    end
  end
end
