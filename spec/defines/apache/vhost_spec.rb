# frozen_string_literal: true

# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::apache::redirect_vhost_https' do
  let(:title) { 'aardvark.default.invalid' }

  let(:pre_condition) do
    <<~EOT
      include apache

      nebula::apache::ssl_keypair { '#{title}':
        chain_crt => 'foo',
      }

      nebula::apache::ssl_keypair { 'something-unrelated.default.invalid':
        chain_crt => 'foo',
      }
    EOT
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it do
        is_expected.to contain_apache__vhost('aardvark.default.invalid-https')
          .with_ssl_cert('/etc/ssl/certs/aardvark.default.invalid.crt')
          .with_ssl_chain('/etc/ssl/certs/foo')
      end
    end
  end
end
