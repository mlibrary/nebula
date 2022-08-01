# frozen_string_literal: true

# Copyright (c) 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::client_cert' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      context 'on a host called default.invalid' do
        let(:node) { 'default.invalid' }
        let(:cert_path) { '/etc/ssl/private/default.invalid.pem' }
        let(:puppet_ssl) { '/etc/puppetlabs/puppet/ssl' }

        it { is_expected.to compile }
        it { is_expected.to contain_concat(cert_path) }
        it { is_expected.to contain_concat__fragment("#{cert_path} cert").with_target(cert_path) }
        it { is_expected.to contain_concat__fragment("#{cert_path} cert").with_source("#{puppet_ssl}/certs/default.invalid.pem") }
        it { is_expected.to contain_concat__fragment("#{cert_path} key").with_target(cert_path) }
        it { is_expected.to contain_concat__fragment("#{cert_path} key").with_source("#{puppet_ssl}/private_keys/default.invalid.pem") }
      end

      context 'on a host called abc' do
        let(:node) { 'abc' }
        let(:cert_path) { '/etc/ssl/private/abc.pem' }
        let(:puppet_ssl) { '/etc/puppetlabs/puppet/ssl' }

        it { is_expected.to compile }
        it { is_expected.to contain_concat(cert_path) }
        it { is_expected.to contain_concat__fragment("#{cert_path} cert").with_target(cert_path) }
        it { is_expected.to contain_concat__fragment("#{cert_path} cert").with_source("#{puppet_ssl}/certs/abc.pem") }
        it { is_expected.to contain_concat__fragment("#{cert_path} key").with_target(cert_path) }
        it { is_expected.to contain_concat__fragment("#{cert_path} key").with_source("#{puppet_ssl}/private_keys/abc.pem") }
      end
    end
  end
end
